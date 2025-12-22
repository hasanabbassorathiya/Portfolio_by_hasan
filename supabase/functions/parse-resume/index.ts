// Supabase Edge Function to parse PDF resumes
// This function extracts text from PDF files and returns structured data

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import pdfParse from 'https://esm.sh/pdf-parse@1.1.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ParsedResumeData {
  name?: string;
  email?: string;
  phone?: string;
  location?: string;
  title?: string;
  bio?: string;
  experiences: Array<{
    company: string;
    position: string;
    description?: string;
    startDate?: string;
    endDate?: string;
    isCurrent: boolean;
  }>;
  skills: string[];
  education: Array<{
    institution: string;
    degree?: string;
    field?: string;
    startDate?: string;
    endDate?: string;
  }>;
  socialLinks: Record<string, string>;
  projects: Array<{
    name: string;
    description?: string;
    technologies: string[];
    url?: string;
  }>;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    const { fileUrl, bucket, fileName } = await req.json();

    if (!fileUrl) {
      throw new Error('fileUrl is required');
    }

    // Download PDF from Supabase Storage
    const { data: fileData, error: downloadError } = await supabaseClient.storage
      .from(bucket || 'resumes')
      .download(fileName || fileUrl.split('/').pop() || 'resume.pdf');

    if (downloadError) {
      throw new Error(`Failed to download file: ${downloadError.message}`);
    }

    // Convert blob to array buffer
    const arrayBuffer = await fileData.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);

    console.log('Starting PDF text extraction...');
    
    // Use pdf-parse library for reliable text extraction
    const text = await extractTextFromPDF(bytes);
    
    console.log(`Extracted text length: ${text.length} characters`);
    console.log('First 500 characters:', text.substring(0, 500));

    // Parse the extracted text
    console.log('Starting text parsing...');
    const parsedData = parseResumeText(text);
    
    console.log('Parsed data:', JSON.stringify(parsedData, null, 2));

    return new Response(
      JSON.stringify({ success: true, data: parsedData }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    );
  } catch (error) {
    console.error('Error in parse-resume function:', error);
    console.error('Error stack:', error.stack);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Unknown error occurred',
        stack: error.stack 
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    );
  }
});

// PDF text extraction using pdf-parse
async function extractTextFromPDF(bytes: Uint8Array): Promise<string> {
  try {
    console.log('Using pdf-parse library to extract text...');
    console.log(`PDF size: ${bytes.length} bytes`);
    
    // pdf-parse expects a Buffer-like object
    // In Deno, we need to convert Uint8Array to Buffer
    const buffer = typeof Buffer !== 'undefined' 
      ? Buffer.from(bytes) 
      : new Uint8Array(bytes); // Fallback for Deno
    
    const data = await pdfParse(buffer);
    const text = data.text;

    if (!text || text.trim().length < 10) {
      throw new Error(
        'Could not extract text from PDF. Please ensure the PDF contains readable text (not scanned images).',
      );
    }

    console.log(`Successfully extracted ${text.length} characters from PDF`);
    return text;
  } catch (error) {
    console.error('pdf-parse extraction failed:', error);
    // Fallback to basic extraction
    console.log('Trying fallback extraction method...');
    return extractTextFromPDFFallback(bytes);
  }
}

// Fallback PDF text extraction (basic approach)
function extractTextFromPDFFallback(bytes: Uint8Array): string {
  let text = '';
  const decoder = new TextDecoder('utf-8', { fatal: false });
  const pdfString = decoder.decode(bytes);
  
  // Extract text between stream markers
  const streamRegex = /stream\s*([\s\S]*?)\s*endstream/g;
  let match;
  
  while ((match = streamRegex.exec(pdfString)) !== null) {
    try {
      const streamContent = match[1];
      const decoded = decoder.decode(
        new Uint8Array(streamContent.split('').map((c) => c.charCodeAt(0))),
      );
      text += decoded + '\n';
    } catch (e) {
      // Skip invalid streams
    }
  }
  
  if (!text || text.trim().length < 10) {
    throw new Error(
      'Could not extract text from PDF. Please ensure the PDF contains readable text (not scanned images).',
    );
  }
  
  return text;
}

// Parse resume text and extract structured data
function parseResumeText(text: string): ParsedResumeData {
  const lines = text.split('\n').map((l) => l.trim()).filter((l) => l.length > 0);
  
  const data: ParsedResumeData = {
    experiences: [],
    skills: [],
    education: [],
    socialLinks: {},
    projects: [],
  };

  // Extract email
  const emailMatch = text.match(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/);
  if (emailMatch) {
    data.email = emailMatch[0];
  }

  // Extract phone
  const phoneMatch = text.match(
    /(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\+\d{10,15}/,
  );
  if (phoneMatch) {
    data.phone = phoneMatch[0];
  }

  // Extract name (usually first line)
  if (lines.length > 0 && lines[0].length < 50 && !lines[0].includes('@')) {
    data.name = lines[0];
  }

  // Extract title (often second line)
  if (lines.length > 1 && lines[1].length < 60) {
    data.title = lines[1];
  }

  // Extract location
  const locationKeywords = ['location', 'address', 'city', 'based in'];
  for (const line of lines.slice(0, 20)) {
    const lower = line.toLowerCase();
    for (const keyword of locationKeywords) {
      if (lower.includes(keyword)) {
        data.location = line.split(':').pop()?.trim() || line.replace(keyword, '').trim();
        break;
      }
    }
    if (data.location) break;
  }

  // Extract work experience with better parsing
  data.experiences = extractWorkExperience(text, lines);

  // Extract skills with better parsing
  data.skills = extractSkills(text, lines);

  // Extract social links
  data.socialLinks = extractSocialLinks(text);

  // Extract projects/works
  data.projects = extractProjects(text, lines);

  // Extract bio/summary
  data.bio = extractBio(text, lines);

  return data;
}

// Enhanced work experience extraction
function extractWorkExperience(text: string, lines: string[]): Array<{
  company: string;
  position: string;
  description?: string;
  startDate?: string;
  endDate?: string;
  isCurrent: boolean;
}> {
  const experiences: Array<{
    company: string;
    position: string;
    description?: string;
    startDate?: string;
    endDate?: string;
    isCurrent: boolean;
  }> = [];

  console.log('Extracting work experience...');
  console.log(`Total lines: ${lines.length}`);
  
  const experienceKeywords = [
    'work experience', 'employment', 'professional experience',
    'experience', 'work history', 'career', 'employment history',
    'professional background', 'employment record',
  ];

  let expStartIndex = -1;
  for (let i = 0; i < lines.length; i++) {
    const lower = lines[i].toLowerCase().trim();
    for (const keyword of experienceKeywords) {
      // More flexible matching
      if (lower.includes(keyword) || lower === keyword || lower.startsWith(keyword + ':') || lower.startsWith(keyword + ' ')) {
        expStartIndex = i;
        console.log(`Found experience section at line ${i}: "${lines[i]}"`);
        break;
      }
    }
    if (expStartIndex !== -1) break;
  }

  if (expStartIndex === -1) {
    console.log('No experience section found, trying to find experiences throughout document...');
    // Try to find experiences without a section header
    return extractWorkExperienceWithoutHeader(text, lines);
  }

  // Parse experiences section
  let currentExp: any = null;
  let descriptionLines: string[] = [];

  console.log(`Parsing experiences from line ${expStartIndex + 1} to ${Math.min(expStartIndex + 100, lines.length)}`);

  for (let i = expStartIndex + 1; i < Math.min(expStartIndex + 100, lines.length); i++) {
    const line = lines[i];
    const lower = line.toLowerCase();

    // Check if we hit a new section
    const sectionKeywords = ['education', 'skills', 'projects', 'certifications', 'awards', 'references'];
    if (sectionKeywords.some(kw => lower.includes(kw) && line.length < 30)) {
      console.log(`Hit new section at line ${i}: "${line}"`);
      break;
    }

    // Date patterns: MM/YYYY, MM-YYYY, YYYY-MM, Month YYYY, etc.
    const datePattern = /(\d{1,2}[\/\-]\d{4}|\d{4}[\/\-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})/i;
    const hasDate = datePattern.test(line);
    const hasDateRange = /(present|current|now|–|-|to)/i.test(line);
    
    // Also check for common job-related keywords
    const hasJobKeywords = /(developer|engineer|designer|manager|analyst|specialist|consultant|lead|senior|junior|intern)/i.test(line);

    // Check if this is a position/company line
    if (hasDate || hasDateRange || (hasJobKeywords && line.length > 10 && line.length < 100 && !line.includes('@'))) {
      // Save previous experience if exists
      if (currentExp) {
        if (descriptionLines.length > 0) {
          currentExp.description = descriptionLines.join(' ').trim();
        }
        experiences.push(currentExp);
        descriptionLines = [];
      }

      // Parse new experience entry
      const dateMatch = line.match(datePattern);
      const dateRangeMatch = line.match(/(\d{1,2}[\/\-]\d{4}|\d{4}[\/\-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})\s*[-–to]+\s*(\d{1,2}[\/\-]\d{4}|\d{4}[\/\-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}|present|current)/i);

      let startDate: string | undefined;
      let endDate: string | undefined;
      let isCurrent = false;

      if (dateRangeMatch) {
        startDate = parseDate(dateRangeMatch[1]);
        if (dateRangeMatch[3] && /present|current/i.test(dateRangeMatch[3])) {
          isCurrent = true;
        } else if (dateRangeMatch[3]) {
          endDate = parseDate(dateRangeMatch[3]);
        }
      } else if (dateMatch) {
        startDate = parseDate(dateMatch[0]);
      }

      // Extract position and company
      let position = '';
      let company = '';

      // Try different patterns: "Position at Company", "Company | Position", etc.
      const atPattern = /(.+?)\s+at\s+(.+)/i;
      const pipePattern = /(.+?)\s*[|•]\s*(.+)/;
      const dashPattern = /(.+?)\s*[-–]\s*(.+)/;

      let positionCompany = line;
      // Remove dates from the line for parsing
      positionCompany = positionCompany.replace(datePattern, '').replace(/present|current/gi, '').trim();

      if (atPattern.test(positionCompany)) {
        const match = positionCompany.match(atPattern);
        if (match) {
          position = match[1].trim();
          company = match[2].trim();
        }
      } else if (pipePattern.test(positionCompany)) {
        const match = positionCompany.match(pipePattern);
        if (match) {
          company = match[1].trim();
          position = match[2].trim();
        }
      } else if (dashPattern.test(positionCompany)) {
        const match = positionCompany.match(dashPattern);
        if (match) {
          position = match[1].trim();
          company = match[2].trim();
        }
      } else {
        // If no pattern matches, try to split by common separators
        const parts = positionCompany.split(/\s+at\s+|\s*[|•]\s*|\s*[-–]\s*/i);
        if (parts.length >= 2) {
          position = parts[0].trim();
          company = parts[1].trim();
        } else if (parts.length === 1) {
          position = parts[0].trim();
        }
      }

      if (position || company) {
        currentExp = {
          company: company || 'Unknown Company',
          position: position || 'Position',
          startDate,
          endDate,
          isCurrent,
        };
        console.log(`Found experience: ${position} at ${company}`);
      }
    } else if (currentExp && line.length > 10 && !line.match(/^[A-Z][a-z]+\s+\d{4}/)) {
      // This might be a description line (but not a date line)
      descriptionLines.push(line);
    }
  }

  // Save last experience
  if (currentExp) {
    if (descriptionLines.length > 0) {
      currentExp.description = descriptionLines.join(' ').trim();
    }
    experiences.push(currentExp);
    console.log(`Added experience: ${currentExp.position} at ${currentExp.company}`);
  }

  console.log(`Total experiences extracted: ${experiences.length}`);
  return experiences;
}

// Extract work experience without a clear section header
function extractWorkExperienceWithoutHeader(text: string, lines: string[]): Array<{
  company: string;
  position: string;
  description?: string;
  startDate?: string;
  endDate?: string;
  isCurrent: boolean;
}> {
  console.log('Trying to extract experiences without section header...');
  const experiences: Array<{
    company: string;
    position: string;
    description?: string;
    startDate?: string;
    endDate?: string;
    isCurrent: boolean;
  }> = [];

  // Look for patterns like: "Position at Company" or "Company | Position" with dates
  const datePattern = /(\d{1,2}[\/\-]\d{4}|\d{4}[\/\-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})/i;
  const jobKeywords = /(developer|engineer|designer|manager|analyst|specialist|consultant|lead|senior|junior|intern|director|coordinator|assistant)/i;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.length < 10 || line.length > 150) continue;

    // Check if line has date and job keywords
    if (datePattern.test(line) && jobKeywords.test(line)) {
      const dateMatch = line.match(datePattern);
      const dateRangeMatch = line.match(/(\d{1,2}[\/\-]\d{4}|\d{4}[\/\-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})\s*[-–to]+\s*(\d{1,2}[\/\-]\d{4}|\d{4}[\/\-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}|present|current)/i);

      let startDate: string | undefined;
      let endDate: string | undefined;
      let isCurrent = false;

      if (dateRangeMatch) {
        startDate = parseDate(dateRangeMatch[1]);
        if (dateRangeMatch[3] && /present|current/i.test(dateRangeMatch[3])) {
          isCurrent = true;
        } else if (dateRangeMatch[3]) {
          endDate = parseDate(dateRangeMatch[3]);
        }
      } else if (dateMatch) {
        startDate = parseDate(dateMatch[0]);
      }

      // Extract position and company
      let positionCompany = line.replace(datePattern, '').replace(/present|current/gi, '').trim();
      
      const atPattern = /(.+?)\s+at\s+(.+)/i;
      const pipePattern = /(.+?)\s*[|•]\s*(.+)/;
      
      let position = '';
      let company = '';

      if (atPattern.test(positionCompany)) {
        const match = positionCompany.match(atPattern);
        if (match) {
          position = match[1].trim();
          company = match[2].trim();
        }
      } else if (pipePattern.test(positionCompany)) {
        const match = positionCompany.match(pipePattern);
        if (match) {
          company = match[1].trim();
          position = match[2].trim();
        }
      } else {
        // Try to split by common separators
        const parts = positionCompany.split(/\s+at\s+|\s*[|•]\s*|\s*[-–]\s*/i);
        if (parts.length >= 2) {
          position = parts[0].trim();
          company = parts[1].trim();
        } else if (parts.length === 1 && parts[0].length > 5) {
          position = parts[0].trim();
        }
      }

      if (position || company) {
        experiences.push({
          company: company || 'Unknown Company',
          position: position || 'Position',
          startDate,
          endDate,
          isCurrent,
        });
        console.log(`Found experience (no header): ${position} at ${company}`);
      }
    }
  }

  console.log(`Total experiences extracted (no header): ${experiences.length}`);
  return experiences;
}

// Parse date string to YYYY-MM-DD format
function parseDate(dateStr: string): string | undefined {
  if (!dateStr) return undefined;

  // MM/YYYY or MM-YYYY
  const mmYyyy = dateStr.match(/(\d{1,2})[\/\-](\d{4})/);
  if (mmYyyy) {
    const month = mmYyyy[1].padStart(2, '0');
    return `${mmYyyy[2]}-${month}-01`;
  }

  // YYYY-MM or YYYY-MM-DD
  const yyyyMm = dateStr.match(/(\d{4})[\/\-](\d{1,2})(?:[\/\-](\d{1,2}))?/);
  if (yyyyMm) {
    const month = yyyyMm[2].padStart(2, '0');
    const day = yyyyMm[3] ? yyyyMm[3].padStart(2, '0') : '01';
    return `${yyyyMm[1]}-${month}-${day}`;
  }

  // Month YYYY (e.g., "January 2020")
  const monthNames: Record<string, string> = {
    jan: '01', feb: '02', mar: '03', apr: '04', may: '05', jun: '06',
    jul: '07', aug: '08', sep: '09', oct: '10', nov: '11', dec: '12',
  };
  const monthYyyy = dateStr.match(/([a-z]+)\s+(\d{4})/i);
  if (monthYyyy) {
    const month = monthNames[monthYyyy[1].toLowerCase().substring(0, 3)];
    if (month) {
      return `${monthYyyy[2]}-${month}-01`;
    }
  }

  return undefined;
}

// Enhanced skills extraction
function extractSkills(text: string, lines: string[]): string[] {
  console.log('Extracting skills...');
  const skills: string[] = [];
  const skillKeywords = ['skills', 'technical skills', 'competencies', 'expertise', 'technologies', 'tools', 'technical expertise'];
  
  let skillsStartIndex = -1;
  for (let i = 0; i < lines.length; i++) {
    const lower = lines[i].toLowerCase().trim();
    for (const keyword of skillKeywords) {
      // More flexible matching
      if (lower.includes(keyword) || lower === keyword || lower.startsWith(keyword + ':') || lower.startsWith(keyword + ' ')) {
        skillsStartIndex = i;
        console.log(`Found skills section at line ${i}: "${lines[i]}"`);
        break;
      }
    }
    if (skillsStartIndex !== -1) break;
  }

  // Common skills/technologies
  const commonSkills = [
    'Flutter', 'Dart', 'React', 'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'C#',
    'Node.js', 'Express', 'Next.js', 'Vue', 'Angular', 'Svelte',
    'MongoDB', 'PostgreSQL', 'MySQL', 'SQLite', 'Redis',
    'Firebase', 'Supabase', 'AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes',
    'Git', 'GitHub', 'GitLab', 'CI/CD', 'Jenkins',
    'Figma', 'Adobe XD', 'Sketch', 'Photoshop', 'Illustrator',
    'UI/UX', 'HTML', 'CSS', 'SASS', 'SCSS', 'Tailwind', 'Bootstrap',
    'Swift', 'Kotlin', 'React Native', 'Flutter', 'Ionic',
    'REST API', 'GraphQL', 'gRPC', 'WebSocket',
    'Agile', 'Scrum', 'JIRA', 'Trello',
  ];

  const lowerText = text.toLowerCase();
  
  // Extract from skills section
  if (skillsStartIndex !== -1) {
    console.log(`Extracting skills from line ${skillsStartIndex + 1}`);
    for (let i = skillsStartIndex + 1; i < Math.min(skillsStartIndex + 30, lines.length); i++) {
      const line = lines[i];
      // Check if we hit a new section
      const sectionKeywords = ['experience', 'education', 'projects', 'certifications', 'work'];
      if (sectionKeywords.some(kw => line.toLowerCase().includes(kw) && line.length < 30)) {
        console.log(`Hit new section at line ${i}: "${line}"`);
        break;
      }
      
      // Extract comma-separated or bullet-pointed skills
      if (line.includes(',') || line.includes('•') || line.includes('-') || line.includes('|')) {
        const lineSkills = line.split(/[,•\-|]/).map(s => s.trim()).filter(s => s.length > 0 && s.length < 50);
        skills.push(...lineSkills);
        console.log(`Extracted skills from line: ${lineSkills.join(', ')}`);
      } else if (line.length > 2 && line.length < 50 && !line.includes('@') && !line.match(/^\d/)) {
        // Single skill per line (but not a date or email)
        skills.push(line.trim());
      }
    }
  } else {
    console.log('No skills section found, searching throughout document...');
  }

  // Also check for common skills throughout the document
  // Also check for common skills throughout the document
  const lowerText = text.toLowerCase();
  for (const skill of commonSkills) {
    if (lowerText.includes(skill.toLowerCase()) && !skills.includes(skill)) {
      skills.push(skill);
      console.log(`Found skill in document: ${skill}`);
    }
  }

  const uniqueSkills = [...new Set(skills)]; // Remove duplicates
  console.log(`Total skills extracted: ${uniqueSkills.length}`);
  return uniqueSkills;
}

// Enhanced social links extraction
function extractSocialLinks(text: string): Record<string, string> {
  const links: Record<string, string> = {};
  const urlPattern =
    /https?:\/\/(?:www\.)?(linkedin\.com|github\.com|twitter\.com|x\.com|facebook\.com|instagram\.com|behance\.net|dribbble\.com)\/[\w/.-]+/gi;
  
  const urlMatches = text.matchAll(urlPattern);
  for (const match of urlMatches) {
    const url = match[0];
    const domain = match[1].toLowerCase();
    let platform = 'unknown';
    
    if (domain.includes('linkedin')) platform = 'linkedin';
    else if (domain.includes('github')) platform = 'github';
    else if (domain.includes('twitter') || domain.includes('x.com')) platform = 'twitter';
    else if (domain.includes('facebook')) platform = 'facebook';
    else if (domain.includes('instagram')) platform = 'instagram';
    else if (domain.includes('behance')) platform = 'behance';
    else if (domain.includes('dribbble')) platform = 'dribbble';
    
    if (platform !== 'unknown' && !links[platform]) {
      links[platform] = url;
    }
  }
  
  return links;
}

// Extract projects/works from resume
function extractProjects(text: string, lines: string[]): Array<{
  name: string;
  description?: string;
  technologies: string[];
  url?: string;
}> {
  const projects: Array<{
    name: string;
    description?: string;
    technologies: string[];
    url?: string;
  }> = [];

  const projectKeywords = ['projects', 'portfolio', 'work samples', 'key projects', 'notable projects'];
  
  let projectsStartIndex = -1;
  for (let i = 0; i < lines.length; i++) {
    const lower = lines[i].toLowerCase().trim();
    for (const keyword of projectKeywords) {
      if (lower === keyword || lower.startsWith(keyword + ':') || lower.startsWith(keyword + ' ')) {
        projectsStartIndex = i;
        break;
      }
    }
    if (projectsStartIndex !== -1) break;
  }

  if (projectsStartIndex === -1) return projects;

  let currentProject: any = null;
  let descriptionLines: string[] = [];

  for (let i = projectsStartIndex + 1; i < Math.min(projectsStartIndex + 50, lines.length); i++) {
    const line = lines[i];
    const lower = line.toLowerCase();

    // Check if we hit a new section
    const sectionKeywords = ['experience', 'education', 'skills', 'certifications'];
    if (sectionKeywords.some(kw => lower.includes(kw) && line.length < 30)) {
      break;
    }

    // Check if this is a project title (usually bold or standalone line)
    if (line.length > 5 && line.length < 80 && !line.includes('@') && !line.includes('http')) {
      // Save previous project
      if (currentProject) {
        if (descriptionLines.length > 0) {
          currentProject.description = descriptionLines.join(' ').trim();
        }
        projects.push(currentProject);
        descriptionLines = [];
      }

      // Extract URL if present
      const urlMatch = line.match(/https?:\/\/[^\s]+/);
      const url = urlMatch ? urlMatch[0] : undefined;

      // Extract technologies (look for common tech keywords)
      const techKeywords = ['React', 'Flutter', 'Node', 'Python', 'JavaScript', 'TypeScript', 'Vue', 'Angular'];
      const technologies: string[] = [];
      for (const tech of techKeywords) {
        if (line.toLowerCase().includes(tech.toLowerCase())) {
          technologies.push(tech);
        }
      }

      currentProject = {
        name: line.replace(/https?:\/\/[^\s]+/g, '').trim(),
        technologies,
        url,
      };
    } else if (currentProject && line.length > 10) {
      // This might be a description line
      descriptionLines.push(line);
      
      // Also check for technologies in description
      const techKeywords = ['React', 'Flutter', 'Node', 'Python', 'JavaScript', 'TypeScript', 'Vue', 'Angular', 'MongoDB', 'PostgreSQL', 'AWS'];
      for (const tech of techKeywords) {
        if (line.toLowerCase().includes(tech.toLowerCase()) && !currentProject.technologies.includes(tech)) {
          currentProject.technologies.push(tech);
        }
      }
    }
  }

  // Save last project
  if (currentProject) {
    if (descriptionLines.length > 0) {
      currentProject.description = descriptionLines.join(' ').trim();
    }
    projects.push(currentProject);
  }

  return projects;
}

// Extract bio/summary
function extractBio(text: string, lines: string[]): string | undefined {
  const bioKeywords = ['summary', 'about', 'profile', 'objective', 'overview', 'professional summary'];
  
  let bioStartIndex = -1;
  for (let i = 0; i < Math.min(20, lines.length); i++) {
    const lower = lines[i].toLowerCase().trim();
    for (const keyword of bioKeywords) {
      if (lower === keyword || lower.startsWith(keyword + ':') || lower.startsWith(keyword + ' ')) {
        bioStartIndex = i;
        break;
      }
    }
    if (bioStartIndex !== -1) break;
  }

  if (bioStartIndex === -1) return undefined;

  const bioLines: string[] = [];
  for (let i = bioStartIndex + 1; i < Math.min(bioStartIndex + 10, lines.length); i++) {
    const line = lines[i];
    // Stop if we hit a new section
    if (line.length < 30 && (
      line.toLowerCase().includes('experience') ||
      line.toLowerCase().includes('education') ||
      line.toLowerCase().includes('skills')
    )) {
      break;
    }
    if (line.length > 20) {
      bioLines.push(line);
    } else {
      break;
    }
  }

  return bioLines.length > 0 ? bioLines.join(' ').trim() : undefined;
}


