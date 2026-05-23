-- Enable standard UUID generation extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. STORES SENDER IDENTITY
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    company_name VARCHAR(150),
    company_domain VARCHAR(100), -- Target used for the n8n background web scraper
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. STORES MULTI-STAGE AI ROUTING ANALYTICS 
CREATE TABLE inquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    raw_message TEXT NOT NULL,
    scraped_company_desc TEXT,       -- Enriched profile metadata fetched from n8n
    ai_category VARCHAR(50),         -- Classifications (e.g., Sales, Support, Spam)
    ai_sentiment VARCHAR(30),        -- Priority flags (e.g., Urgent, Neutral, Negative)
    estimated_budget INT DEFAULT 0,  -- Financial value metric extracted by LLM
    ai_cost_saved NUMERIC(6, 4),     -- System efficiency metrics tracking costs saved
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. DRIVES THE VISUAL REAL-TIME KANBAN BOARD STAGES
CREATE TABLE deals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    inquiry_id UUID REFERENCES inquiries(id) ON DELETE CASCADE,
    pipeline_stage VARCHAR(50) DEFAULT 'New', -- Tracks stages (e.g., New, Qualified, Hot_Lead, Spam)
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Production Performance Indexing for fast foreign key lookups
CREATE INDEX idx_inquiries_contact_id ON inquiries(contact_id);
CREATE INDEX idx_deals_contact_id ON deals(contact_id);
CREATE INDEX idx_deals_inquiry_id ON deals(inquiry_id);