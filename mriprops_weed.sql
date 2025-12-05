CREATE TABLE IF NOT EXISTS `weed_plants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner` VARCHAR(50) NOT NULL,           -- citizenid/identifier
    `strain` VARCHAR(20) NOT NULL,          -- blue, green, orange, etc.
    `stage` TINYINT DEFAULT 0,              -- 0=small, 1=med, 2=large
    `planted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `coords` LONGTEXT NOT NULL,             -- JSON: {x, y, z, heading}
    `fertilized` BOOLEAN DEFAULT FALSE,     -- Optional: fertilizer
    INDEX `owner_idx` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
