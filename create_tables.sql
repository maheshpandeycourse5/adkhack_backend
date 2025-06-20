-- Create the ad_campaigns table
CREATE TABLE IF NOT EXISTS ad_campaigns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    uploaded_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    score VARCHAR(10),
    video_path TEXT,
    content TEXT,
    guidelines TEXT,
    file_type VARCHAR(50) NOT NULL,
    download_link TEXT,
    approval_date DATE,
    conflicts TEXT[] DEFAULT ARRAY[]::TEXT[],
    suggestions TEXT[] DEFAULT ARRAY[]::TEXT[],
    file_url TEXT
);

-- Example insert statement
-- INSERT INTO ad_campaigns (
--     name,
--     uploaded_date,
--     status,
--     score,
--     video_path,
--     content,
--     guidelines,
--     file_type,
--     download_link,
--     approval_date,
--     conflicts,
--     suggestions,
--     file_url
-- ) VALUES (
--     'Summer Campaign - Instagram Post',
--     '2025-06-15',
--     'Approved',
--     '92',
--     '',
--     '',
--     '',
--     'Instagram URL',
--     '#',
--     '2025-06-16',
--     ARRAY['', '', ''],
--     ARRAY['', '', ''],
--     'https://instagram.com/p/example123'
-- );
