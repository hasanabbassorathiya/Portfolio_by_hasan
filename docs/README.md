# Documentation Index

Welcome to the Portfolio CMS documentation. This directory contains all the guides and resources you need to set up, configure, and deploy your portfolio.

## 📚 Documentation Structure

```
docs/
├── README.md (this file)
├── sql/                    # Database migrations
├── api/                    # API documentation
│   ├── API.md             # Complete API reference
│   ├── POSTMAN_SETUP.md   # Postman collection setup
│   └── portfolio-api.postman_collection.json
├── setup/                  # Setup guides
│   ├── SETUP.md           # Complete setup guide
│   ├── DATABASE.md        # Database setup
│   └── DEPLOYMENT.md      # Deployment guide
└── guides/                 # Feature guides
    ├── ADMIN_PANEL_GUIDE.md
    ├── DESIGN_SYSTEM.md
    └── MODERN_UI_GUIDE.md
```

## 🚀 Quick Start

1. **New to the project?** Start with [Setup Guide](setup/SETUP.md)
2. **Setting up database?** See [Database Setup](setup/DATABASE.md)
3. **Want to test APIs?** Check [API Documentation](api/API.md) and [Postman Setup](api/POSTMAN_SETUP.md)
4. **Ready to deploy?** Follow [Deployment Guide](setup/DEPLOYMENT.md)

## 📖 Documentation by Topic

### Setup & Installation

- **[Complete Setup Guide](setup/SETUP.md)** - Step-by-step setup from scratch
- **[Database Setup](setup/DATABASE.md)** - Database migrations and configuration
- **[Deployment Guide](setup/DEPLOYMENT.md)** - Deploy to production

### API & Integration

- **[API Documentation](api/API.md)** - Complete API reference
- **[Postman Collection](api/portfolio-api.postman_collection.json)** - Import for API testing
- **[Postman Setup Guide](api/POSTMAN_SETUP.md)** - How to use the Postman collection

### Features & Guides

- **[Admin Panel Guide](guides/ADMIN_PANEL_GUIDE.md)** - Using the admin panel
- **[Design System](guides/DESIGN_SYSTEM.md)** - Design principles and components
- **[Modern UI Guide](guides/MODERN_UI_GUIDE.md)** - UI/UX guidelines

### Database

- **[SQL Migrations](sql/)** - All database migration files
  - `001_initial_schema.sql` - Base tables
  - `002_seed_data.sql` - Seed data
  - `003_analytics_and_config.sql` - Analytics tables
  - `004_admin_policies.sql` - RLS policies
  - `005_fix_analytics_rls.sql` - Analytics RLS fix
  - `006_fix_blog_rls.sql` - Blog RLS fix
  - `007_add_blog_status_and_scheduling.sql` - Blog features
  - `008_setup_storage_policies.sql` - Storage policies

## 🔍 Finding What You Need

### I want to...

- **Set up the project**: [Setup Guide](setup/SETUP.md)
- **Configure the database**: [Database Setup](setup/DATABASE.md)
- **Test the API**: [API Documentation](api/API.md) + [Postman Setup](api/POSTMAN_SETUP.md)
- **Deploy to production**: [Deployment Guide](setup/DEPLOYMENT.md)
- **Use the admin panel**: [Admin Panel Guide](guides/ADMIN_PANEL_GUIDE.md)
- **Customize the design**: [Design System](guides/DESIGN_SYSTEM.md)
- **Understand the database**: [SQL Migrations](sql/)

## 📝 Contributing to Documentation

If you find errors or want to improve the documentation:

1. Edit the relevant `.md` file
2. Test your changes
3. Submit a pull request

## 🆘 Need Help?

- Check the relevant guide above
- Review the main [README](../README.md)
- Open an issue on GitHub

---

**Happy coding! 🚀**

