// Candidate engagement scopes, not fixed packages or promises of client outcomes.
export const services = [
  {
    slug: 'flutter-app-development',
    index: '01',
    tag: 'Mobile · Flutter',
    title: 'Flutter app development',
    copy: 'Build a new iOS and Android app, or extend the one you have, with clear architecture and an owner for the mobile delivery.',
    points: ['Projects from scratch or existing apps', 'Flutter, Dart, Riverpod and Firebase', 'Testing, release preparation and handover'],
    featured: true,
    seoTitle: 'Flutter App Development · Hasan Abbas Sorathiya',
    seoDescription: 'Flutter app development for iOS and Android: new products, existing apps, API integration, testing and release preparation with Hasan Abbas Sorathiya.',
    overview: [
      'A mobile product is more than a set of screens. Sign-in, unreliable networks, permissions, content updates and store requirements all shape the build. I help turn a product brief into a Flutter application with explicit responsibilities between the interface, state and data layers.',
      'The engagement can start from scratch or inside an existing codebase. My strongest production experience is Flutter delivery across consumer, lending, mobility and community products. Web, tablet and TV requirements are assessed separately rather than treated as automatic extensions of a phone app.',
    ],
    audience: {
      for: [
        'Founders with a defined customer problem who need a first working product, not just a clickable demo.',
        'Product teams that need a senior Flutter engineer to own a feature, improve an existing app or work alongside their backend and design teams.',
      ],
      notFor: [
        'A promise that every platform will behave identically without platform-specific design, integration and testing.',
        'A fixed launch date or store approval guarantee before reviewing the scope, accounts, dependencies and current code.',
      ],
    },
    deliverables: [
      'A written feature boundary, platform list and acceptance criteria, including what is deliberately outside the first release.',
      'A Flutter codebase with reusable UI components, explicit state management and documented API or Firebase integration points.',
      'Agreed product flows with loading, empty, error and permission states; offline behaviour is included where the scope requires it.',
      'Tests around the agreed critical paths, device checks and a release-readiness checklist for the target stores.',
      'Build and handover notes covering environment setup, ownership of accounts and the maintenance work that remains.',
    ],
    process: [
      { title: 'Map the product', copy: 'Review the audience, main journeys, designs and existing services. Identify the smallest useful release and the dependencies that could block it.' },
      { title: 'Set the foundation', copy: 'Choose module and state boundaries, agree API contracts and implement a representative end-to-end flow before expanding the screen count.' },
      { title: 'Build and review', copy: 'Work through agreed milestones with demonstrable builds. Test failure states as well as the happy path and record decisions as the product evolves.' },
      { title: 'Prepare the handover', copy: 'Check the agreed devices and release configuration, document the build process and confirm who owns submission, support and follow-up changes.' },
    ],
    evidence: [
      { label: 'EVLAB · mobile engineering case study', to: '/work/evlab', copy: 'Mobile engineering leadership across Flutter architecture, API integration, release management and production support at Chalhoub Group.' },
      { label: 'Duas and Aamal · own product', to: '/apps/duas-and-aamal', copy: 'A published Flutter app with multilingual content, offline access and prayer features, built and maintained as an independent product.' },
      { label: 'Lumio TV · cross-platform work', to: '/apps/lumio-tv', copy: 'A player with mobile, web and TV experiences, including explicit playback states and remote-first navigation.' },
    ],
    questions: [
      { question: 'Can you build my app from scratch?', answer: 'Yes. We start by defining the user problem, core journeys and what the first version must prove. Design, backend work and release support are scoped explicitly so a new app does not quietly become several unplanned projects.' },
      { question: 'Can you join an existing Flutter project?', answer: 'Yes. I first review the architecture, dependency versions, build setup and the feature you want to change. A targeted improvement may be more useful than a rewrite; that decision should follow the review, not precede it.' },
      { question: 'Are store submission and ongoing maintenance included?', answer: 'They can be part of the written scope. You retain ownership of developer accounts and product assets. Store review decisions, third-party service fees and a continuing maintenance arrangement are separate considerations, not guaranteed outcomes of development.' },
    ],
    enquiry: 'Send the main user journey, target platforms, any designs or existing app links, and the backend you already have. Include your constraints and whether this is a new product or an existing build.',
  },
  {
    slug: 'ai-integration-automation',
    index: '02',
    tag: 'AI · Workflows',
    title: 'AI integration & n8n automation',
    copy: 'Add a useful AI capability or connect repetitive work across systems, with evaluation, permissions and human review built into the scope.',
    points: ['LLM integrations, RAG and agents', 'n8n workflows and API connections', 'MCP tools, evaluation and guardrails'],
    featured: true,
    seoTitle: 'AI Integration & n8n Automation · Hasan Abbas Sorathiya',
    seoDescription: 'Scope and build LLM integrations, RAG, MCP tools and n8n automation with explicit permissions, evaluation and human-review boundaries.',
    overview: [
      'The starting point is a task, not a model. A support assistant, a content workflow and a document search tool need different data access, review steps and failure behaviour. I help decide where an LLM adds value and where a normal API call or deterministic workflow is the better tool.',
      'Candidate work includes OpenAI or Claude integrations, retrieval over approved content, MCP tools and n8n workflows that connect existing services. We define what the system may read, what it may change and when a person must approve an action before connecting it to business data.',
    ],
    audience: {
      for: [
        'Product teams adding a bounded AI feature to a web or Flutter application with a clear user task and approved data sources.',
        'Operations teams with repetitive work across documented APIs who can identify a workflow owner and review exceptions.',
      ],
      notFor: [
        'An autonomous agent given unrestricted access to customer data, payments or production systems without approval boundaries.',
        'Guaranteed model accuracy, guaranteed cost savings, or a replacement for expert judgement in high-stakes decisions.',
      ],
    },
    deliverables: [
      'A workflow map describing triggers, inputs, tools, permissions, approval steps and the conditions that stop execution.',
      'An agreed integration: an application feature, retrieval pipeline, MCP tool or n8n workflow connected to the selected APIs.',
      'A representative evaluation set and documented acceptance checks, including unsupported questions and tool failures.',
      'Handling for timeouts, retries and duplicate events where relevant, plus a defined route for human review or manual recovery.',
      'Setup and handover notes covering credentials management, model and service dependencies, usage visibility and operating limits.',
    ],
    process: [
      { title: 'Observe the task', copy: 'Walk through the current process with its owner. Identify the data, manual decisions and failure cases before choosing an AI or automation approach.' },
      { title: 'Prove a small slice', copy: 'Use approved sample inputs to test one bounded workflow. Compare a model-assisted approach with a simpler rules-based alternative.' },
      { title: 'Connect with controls', copy: 'Integrate the agreed services with limited permissions, explicit approvals for sensitive actions and traceable errors rather than silent retries.' },
      { title: 'Evaluate and hand over', copy: 'Run the agreed examples and failure cases. Document limitations, operating responsibilities and what needs monitoring as inputs or models change.' },
    ],
    evidence: [
      { label: 'wp-mcp-server · public repository', href: 'https://github.com/hasanabbassorathiya/wp-mcp-server', copy: 'A TypeScript MCP server for the WordPress REST API. This is evidence of tool integration work, not a claim of a published n8n client rollout.' },
      { label: 'stoolap-flutter · public repository', href: 'https://github.com/hasanabbassorathiya/stoolap-flutter', copy: 'Flutter bindings for an embedded SQL engine with vector search and reactive streams; relevant building blocks, not a complete managed RAG service.' },
      { label: 'RAG that survives real users · engineering notes', to: '/blog/rag-that-survives-real-users', copy: 'Writing about retrieval boundaries and evaluation. It explains the approach rather than presenting a client result or accuracy guarantee.' },
    ],
    questions: [
      { question: 'Do you offer n8n automation as well as AI features?', answer: 'Yes. n8n is a candidate for connecting services, routing events and adding review steps. It does not need an LLM in every workflow. The choice depends on your integrations, hosting requirements and who will maintain the automation.' },
      { question: 'Can an assistant use our private documents?', answer: 'Potentially, after reviewing data ownership, access rules and provider terms. Retrieval must respect the permissions of the requesting user. We agree which content may leave your environment and how sensitive information is handled before connecting a model.' },
      { question: 'Can you guarantee the AI will always be correct?', answer: 'No. Model outputs need task-specific evaluation, clear limitations and fallback behaviour. For workflows that change records or trigger external actions, we define deterministic checks and human approval where appropriate rather than treating generated text as proof of success.' },
    ],
    enquiry: 'Describe the manual task or AI feature, the systems involved, a representative input and the expected result. Share data-sensitivity constraints and who should approve actions; do not send credentials or private customer data.',
  },
  {
    slug: 'full-stack-api-development',
    index: '03',
    tag: 'Web · Backend',
    title: 'MERN & full-stack API development',
    copy: 'Connect your product from interface to data: React applications, Node.js services and APIs that a mobile or web team can actually use.',
    points: ['React, Node.js, Express and MongoDB', 'API contracts, authentication and integrations', 'New products and existing backend work'],
    featured: true,
    seoTitle: 'MERN & Full-Stack API Development · Hasan Abbas Sorathiya',
    seoDescription: 'React, Node.js, Express and MongoDB development, API integration and backend workflows with explicit scope, authentication boundaries and handover.',
    overview: [
      'A useful backend starts with the product journeys it must support. I help define data ownership, API contracts and authentication boundaries, then build the agreed web interface and service layer. The aim is a system that another engineer can understand, not a collection of endpoints without an operating model.',
      'MERN is one available stack: MongoDB, Express, React and Node.js. Firebase or an existing backend may be a better fit for a particular product. My public work includes content tooling and integrations; client mobile case studies demonstrate API consumption and coordination, not ownership of every backend behind those apps.',
    ],
    audience: {
      for: [
        'Founders building a scoped product from scratch with a web interface, structured data and a manageable set of integrations.',
        'Mobile and web teams needing an API, an internal tool or a clearer contract between an existing frontend and backend.',
      ],
      notFor: [
        'An assumption that every existing client app in this portfolio had its entire backend designed or built by me.',
        'Unbounded platform replacement, compliance certification or a capacity guarantee without reviewing the actual requirements and infrastructure.',
      ],
    },
    deliverables: [
      'An agreed data model and API contract describing request validation, responses, errors, pagination and access rules where needed.',
      'The scoped React interface and Node.js or Express service implementation, integrated with the chosen database or existing services.',
      'Authentication and authorization checks for agreed roles, with server-side validation rather than relying on interface restrictions.',
      'Tests for critical API behaviour and integration boundaries, including invalid input, denied access and dependency failures.',
      'Environment, API and handover notes covering setup, configuration responsibilities and any separately scoped migration or hosting work.',
    ],
    process: [
      { title: 'Trace the journeys', copy: 'Map users, roles, data and third-party dependencies. Separate essential product flows from speculative platform features.' },
      { title: 'Agree the contract', copy: 'Define endpoints, validation and ownership with the consuming team. Review the data model and access rules before building out the interface.' },
      { title: 'Build a vertical slice', copy: 'Connect one complete journey from React or the mobile client to the API and database, then extend the same tested boundaries.' },
      { title: 'Verify the handoff', copy: 'Exercise success and failure paths, document setup and operating assumptions, and identify remaining hosting, migration or support responsibilities.' },
    ],
    evidence: [
      { label: 'duas-crm · public repository', href: 'https://github.com/hasanabbassorathiya/duas-crm', copy: 'Python-based content operations tooling behind Duas and Aamal. Evidence of backend product work, not a MERN implementation claim.' },
      { label: 'wp-mcp-server · TypeScript integration', href: 'https://github.com/hasanabbassorathiya/wp-mcp-server', copy: 'An inspectable integration with the WordPress REST API that exposes content operations through MCP.' },
      { label: 'Good2Go Loans · mobile API integration', to: '/work/good2go-loans', copy: 'Work on mobile onboarding, authentication and account journeys consuming secure APIs; the case study describes the mobile role.' },
    ],
    questions: [
      { question: 'Does every full-stack project need the MERN stack?', answer: 'No. MERN is an option, not a prerequisite. Existing infrastructure, data relationships, team experience and maintenance requirements should drive the decision. I will scope the integration with your current backend before proposing a replacement.' },
      { question: 'Can you build just the API or just the React interface?', answer: 'Yes. The engagement can cover a single layer if its boundaries are clear. We agree who owns authentication, API contracts, environments and integration testing so the handoff to the other team is explicit.' },
      { question: 'What about payments, migrations and hosting?', answer: 'Those are separate scope items with their own dependencies. Payment-provider requirements, data migration checks, infrastructure access and operating costs need review before commitments. A development brief does not imply a managed hosting or compliance service.' },
    ],
    enquiry: 'Send the key product flows, user roles, existing stack and the API or integration gaps. Include any data migration, hosting or security requirements so those boundaries can be reviewed early.',
  },
  {
    slug: 'app-audit-consulting',
    index: '04',
    tag: 'Specialist · Advisory',
    title: 'App audits & specialist consulting',
    copy: 'Get a grounded second opinion on a Flutter app, architecture or delivery problem before committing to a rewrite or another round of fixes.',
    points: ['Architecture and codebase review', 'Performance and release-readiness investigation', 'Prioritized findings and technical guidance'],
    featured: false,
    seoTitle: 'App Audits & Flutter Consulting · Hasan Abbas Sorathiya',
    seoDescription: 'Flutter app audits and specialist consulting for architecture, performance investigation and release readiness, with evidence-led findings and scoped follow-up.',
    overview: [
      'An audit should help you make a decision. Whether the question is why an app feels slow, why changes keep breaking a flow or whether a rewrite is justified, I start with the symptom and the evidence available. A broad checklist is not a substitute for understanding the product and its constraints.',
      'My perspective comes from leading mobile delivery, reviewing Flutter architecture and supporting releases. This is engineering consulting, not a certified security assessment or legal compliance review. The work can end with findings and a walkthrough, or lead into separately agreed implementation support.',
    ],
    audience: {
      for: [
        'Teams inheriting a Flutter codebase that need to understand its structure, build process and most important maintenance risks.',
        'Product owners deciding between targeted fixes, a refactor or a rewrite, with a specific symptom or delivery concern to investigate.',
      ],
      notFor: [
        'A penetration test, regulatory sign-off, formal accessibility certification or guaranteed approval from an app store.',
        'A promise to diagnose every issue without access to representative code, reproducible builds or relevant non-sensitive diagnostic evidence.',
      ],
    },
    deliverables: [
      'A written review boundary covering the code, app journeys, devices and delivery processes included in the assessment.',
      'Findings tied to observed code or reproducible behaviour, with assumptions and unverified areas clearly separated.',
      'A prioritized action list explaining the impact, dependencies and trade-offs of fixes rather than labelling every issue urgent.',
      'Architecture or release recommendations with an incremental path where possible and a clear explanation when deeper changes are warranted.',
      'A findings walkthrough and handover notes that your team can use to plan work; implementation is only included when agreed.',
    ],
    process: [
      { title: 'Frame the decision', copy: 'Agree the question the review must answer, the people using the findings and the limits of available access.' },
      { title: 'Gather evidence', copy: 'Inspect the selected code paths and build setup. Reproduce reported symptoms and use relevant profiling or diagnostic information where available.' },
      { title: 'Weigh the options', copy: 'Compare targeted fixes, structural changes and the cost of leaving behaviour unchanged. Label assumptions instead of filling gaps with certainty.' },
      { title: 'Make findings usable', copy: 'Walk through priorities with your team, record the recommended next steps and agree whether any implementation or follow-up review is needed.' },
    ],
    evidence: [
      { label: 'EVLAB · architecture and delivery ownership', to: '/work/evlab', copy: 'A mobile lead role covering architecture, cross-team delivery, CI/CD and production support; context for the consulting perspective.' },
      { label: 'Nakheel Marinas · Flutter team leadership', to: '/work/nakheel-marinas', copy: 'Architecture guidance, standards, code review and production delivery with a Flutter team at Belong Interactive.' },
      { label: 'Flutter startup time · technical writing', to: '/blog/flutter-startup-time', copy: 'An engineering discussion of startup investigation. It is not a performance improvement guarantee for another application.' },
    ],
    questions: [
      { question: 'Do you need the entire repository to start?', answer: 'Not always. A symptom, architecture overview and relevant code can help define the review. Deeper findings may require a reproducible build and agreed repository access. Do not email secrets, signing keys or customer records with the initial enquiry.' },
      { question: 'Will the audit include fixes?', answer: 'The default outcome is a documented assessment and prioritized next steps. A small validation change or implementation phase can be agreed separately. Keeping the boundary explicit avoids confusing a review with an open-ended maintenance commitment.' },
      { question: 'Can you help my team rather than replace it?', answer: 'Yes. Consulting can focus on technical decisions, code review, architecture discussions or release preparation alongside your engineers. The goal is to leave the team with clearer reasoning and usable next steps, not create a dependency on one person.' },
    ],
    enquiry: 'Describe the app, the decision you need to make and the symptoms you can reproduce. Share the stack and available diagnostic context, without sending production credentials or customer data.',
  },
  {
    slug: 'digital-platform-development',
    index: '05',
    tag: 'Platforms · WordPress',
    title: 'Digital platforms & WordPress integrations',
    copy: 'Build a content-led website, internal platform or connected WordPress workflow around the people who publish, maintain and use it.',
    points: ['Content platforms and internal tools', 'WordPress REST API and MCP integrations', 'New builds, workflow mapping and handover'],
    featured: false,
    seoTitle: 'Digital Platforms & WordPress Integrations · Hasan Abbas Sorathiya',
    seoDescription: 'Scoped digital platform development, content workflows and WordPress REST API integrations. Platform-specific requirements are reviewed before commitments.',
    overview: [
      'A digital platform needs an operating model as well as a frontend. Who publishes content? Who can approve a change? What happens when an integration fails? I help define those workflows and build the agreed website, portal or supporting tool around them, including projects that begin with no existing codebase.',
      'WordPress work is grounded in PHP/WordPress skills and the public wp-mcp-server repository, which connects MCP tools to the WordPress REST API. That supports a concrete integration offer; it is not evidence of every kind of theme, plugin or commerce engagement. Platform-specific requirements are reviewed before a commitment.',
    ],
    audience: {
      for: [
        'Organizations that need a content-led site or member workflow connected to an existing CMS, API or mobile product.',
        'Teams using WordPress that want a defined REST API integration, content operation or supporting tool with clear access rules.',
      ],
      notFor: [
        'An assumption of advanced Shopify expertise, a Shopify Plus specialization or an existing portfolio of custom Shopify builds.',
        'An unrestricted promise to support every WordPress plugin, recover an unknown hosting environment or guarantee search rankings.',
      ],
    },
    deliverables: [
      'A platform brief covering users, content types, publishing responsibilities, integrations and the first useful release.',
      'The agreed responsive website, portal or content tool, with a defined boundary between presentation and content management.',
      'Scoped WordPress REST API or other service integrations, including access controls and explicit handling of failed operations.',
      'Checks for key publishing and user journeys, broken links, responsive behaviour and the agreed accessibility requirements.',
      'Content and technical handover notes covering routine updates, environment dependencies and separately scoped hosting or support needs.',
    ],
    process: [
      { title: 'Map content and ownership', copy: 'Identify the audience, content model, editorial steps and systems already in place. Decide what the platform must make easier for its operators.' },
      { title: 'Check the platform fit', copy: 'Review WordPress, a custom application or the existing CMS against the actual requirements. Inspect required plugins and APIs rather than assuming compatibility.' },
      { title: 'Build the agreed workflows', copy: 'Implement the presentation and integration paths with representative content. Keep publishing permissions and recovery from failed operations visible.' },
      { title: 'Validate everyday use', copy: 'Walk through editing, publishing and user journeys. Document routine maintenance and agree the boundary of any migration, hosting or ongoing support work.' },
    ],
    evidence: [
      { label: 'wp-mcp-server · WordPress integration source', href: 'https://github.com/hasanabbassorathiya/wp-mcp-server', copy: 'A public TypeScript MCP server for the WordPress REST API: direct evidence for the WordPress integration scope offered here.' },
      { label: 'duas-crm · content operations tooling', href: 'https://github.com/hasanabbassorathiya/duas-crm', copy: 'A content operations CRM connected to an independently maintained app, showing the supporting tools behind a content product.' },
      { label: 'Carvan-e-Hind · community platform', to: '/apps/carvan-e-hind', copy: 'A Flutter community app with events, media and member engagement. Relevant platform experience, not a WordPress or Shopify case study.' },
    ],
    questions: [
      { question: 'What kind of WordPress work do you offer?', answer: 'The clearest fit is REST API integration, connected content workflows and supporting tools, informed by wp-mcp-server. Site, theme, plugin and migration requirements need individual review; the repository does not imply experience with every WordPress setup.' },
      { question: 'Do you take Shopify requests?', answer: 'Shopify requests are scope-assessed before any commitment. I do not claim advanced Shopify expertise or a Shopify-specific delivery track record. Share the requirements so I can explain which parts fit my experience and which need a dedicated Shopify specialist.' },
      { question: 'Can the project start with only an idea?', answer: 'Yes, if we first define the audience, content ownership and the smallest useful set of workflows. The initial scope should distinguish product development from branding, content production, migration and ongoing hosting so responsibilities are clear.' },
    ],
    enquiry: 'Send the platform goal, current site or CMS, content types and integrations you need. Name any required WordPress plugins or Shopify-specific features so the fit can be assessed honestly before work is agreed.',
  },
  {
    slug: 'ui-ux-product-design',
    index: '06',
    tag: 'Product · Interface',
    title: 'UI/UX & product interface design',
    copy: 'Shape the journeys, screens and interaction details of a mobile or web product, with the realities of implementation considered from the start.',
    points: ['User flows, wireframes and interface states', 'Reusable components and responsive layouts', 'Design-to-development collaboration'],
    featured: false,
    seoTitle: 'UI/UX & Product Interface Design · Hasan Abbas Sorathiya',
    seoDescription: 'Engineering-led UI/UX for mobile and web products: user flows, wireframes, reusable interface components and scoped design-to-development handoff.',
    overview: [
      'Interface work starts with what a person is trying to do. I help turn a product brief into clear journeys, screen structure and a reusable interface language, then account for the states that are easy to omit from a polished mockup: slow loading, missing content, errors, permissions and recovery.',
      'This is an engineering-led product design offer, grounded in building mobile interfaces and collaborating with UX/UI teams. I can work within your existing visual direction or shape an initial interface for a scoped product. Brand strategy, specialist research and independent design certification are not implied.',
    ],
    audience: {
      for: [
        'Founders who need to clarify a first product journey before committing to a larger mobile or web build.',
        'Teams with an existing design direction that need practical interface refinement, reusable components or a closer design-to-code handoff.',
      ],
      notFor: [
        'A full-service branding studio engagement, a guaranteed conversion improvement or a claim that client product design was mine alone.',
        'Formal research or accessibility certification without separately agreed expertise, participant access and evaluation scope.',
      ],
    },
    deliverables: [
      'A map of the agreed user journeys, key tasks and points where the interface must explain a decision or recover from an error.',
      'Wireframes and screen specifications for the selected flows, using the existing brand direction or an agreed initial visual treatment.',
      'A reusable component and state inventory covering typography, spacing, controls, validation and feedback for the scoped screens.',
      'Responsive and interaction notes addressing touch, keyboard, focus, text scaling and content variation where relevant to the target platforms.',
      'A reviewable prototype or implemented UI slice in the agreed format, plus a handoff that records decisions and unresolved questions.',
    ],
    process: [
      { title: 'Understand the task', copy: 'Review the audience, available feedback and product constraints. Identify the journey that matters before discussing decorative details.' },
      { title: 'Structure the flow', copy: 'Map decisions and screen order, sketch the content hierarchy and include alternate paths such as errors, empty states and returning users.' },
      { title: 'Make the interface reusable', copy: 'Refine the agreed visual direction into components and states that can be implemented consistently across the selected screens and sizes.' },
      { title: 'Review in context', copy: 'Walk through a prototype or running interface with the team. Validate assumptions against available user feedback and document changes for implementation.' },
    ],
    evidence: [
      { label: 'Duas and Aamal · multilingual product', to: '/apps/duas-and-aamal', copy: 'An independently built app shaped around multilingual content, readable Arabic text and offline use. Inspect the product rather than infer a separate design-agency engagement.' },
      { label: 'Lumio TV · mobile and remote interaction', to: '/apps/lumio-tv', copy: 'A product with phone, web and TV interaction requirements, including focus navigation and legible playback failure states.' },
      { label: 'EVLAB · cross-functional delivery', to: '/work/evlab', copy: 'Collaboration with Product and UX/UI as mobile engineering lead. This is not a claim of sole authorship of the EVLAB design.' },
    ],
    questions: [
      { question: 'Is this a standalone design service or part of development?', answer: 'It can be either, within an agreed scope. A focused journey or interface pass can precede a build, while an existing team may need design-to-code support. We agree the artefacts and handoff format before work begins.' },
      { question: 'Can you work with our designer and existing design system?', answer: 'Yes. I can translate the agreed direction into reusable Flutter or React components, flag missing states and review the running interface with your designer. Changes to brand or visual direction should remain explicit decisions rather than accidental implementation differences.' },
      { question: 'Will you run user research or guarantee better conversion?', answer: 'No conversion outcome is guaranteed. Available feedback can inform the work, and a scoped usability review can help identify friction. Recruiting participants, formal research and specialist accessibility assessment require their own plan and are not assumed to be included.' },
    ],
    enquiry: 'Share the product goal, target users, the journey that needs work and any current designs or brand guidelines. Say whether you need exploration, a handoff for your team or an implemented interface.',
  },
];

export const serviceBySlug = (slug) => services.find((service) => service.slug === slug);
