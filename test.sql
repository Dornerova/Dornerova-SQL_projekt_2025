SELECT *
FROM czechia_district
WHERE code NOT IN (
    SELECT district_code
    FROM not_completed_provider_info_district
);