USE ITSupportAnalytics;
GO

SELECT COUNT(*) AS incident_count
FROM dbo.Incidents;

SELECT 
    priority,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY priority
ORDER BY incident_count DESC;

SELECT 
    category,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY category
ORDER BY incident_count DESC;

SELECT 
    COUNT(*) AS unresolved_incidents
FROM dbo.Incidents
WHERE state NOT IN ('Closed', 'Resolved');

SELECT
    AVG(DATEDIFF(MINUTE, opened_at, resolved_at)) AS avg_resolution_minutes
FROM dbo.Incidents
WHERE resolved_at IS NOT NULL;

SELECT
    priority,
    COUNT(*) AS incident_count,
    AVG(DATEDIFF(MINUTE, opened_at, resolved_at)) AS avg_resolution_minutes
FROM dbo.Incidents
WHERE resolved_at IS NOT NULL
GROUP BY priority
ORDER BY avg_resolution_minutes DESC;

SELECT
    assignment_group,
    COUNT(*) AS incident_count
FROM dbo.Incidents
WHERE assignment_group IS NOT NULL
  AND LTRIM(RTRIM(assignment_group)) <> ''
GROUP BY assignment_group
ORDER BY incident_count DESC;

SELECT
    state,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY state
ORDER BY incident_count DESC;

SELECT
    YEAR(opened_at) AS year,
    MONTH(opened_at) AS month,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY
    YEAR(opened_at),
    MONTH(opened_at)
ORDER BY
    year,
    month;

    SELECT
    category,
    priority,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY
    category,
    priority
ORDER BY
    category,
    incident_count DESC;

SELECT TOP 10
    short_description,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY short_description
ORDER BY incident_count DESC;

SELECT
    category,
    COUNT(*) AS resolved_incidents,
    AVG(DATEDIFF(MINUTE, opened_at, resolved_at)) AS avg_resolution_minutes
FROM dbo.Incidents
WHERE resolved_at IS NOT NULL
GROUP BY category
ORDER BY avg_resolution_minutes DESC;

SELECT
    CASE
        WHEN priority IN ('P1 Critical', 'P2 High')
            THEN 'High Priority'
        WHEN priority = 'P3 Moderate'
            THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS priority_group,
    COUNT(*) AS incident_count
FROM dbo.Incidents
GROUP BY
    CASE
        WHEN priority IN ('P1 Critical', 'P2 High')
            THEN 'High Priority'
        WHEN priority = 'P3 Moderate'
            THEN 'Medium Priority'
        ELSE 'Low Priority'
    END
ORDER BY incident_count DESC;

SELECT TOP 10
    number,
    category,
    priority,
    opened_at,
    resolved_at,
    DATEDIFF(MINUTE, opened_at, resolved_at) AS resolution_minutes,
    DATEDIFF(DAY, opened_at, resolved_at) AS resolution_days
FROM dbo.Incidents
WHERE resolved_at IS NOT NULL
ORDER BY resolution_minutes DESC;

WITH ResolutionTimes AS
(
    SELECT
        DATEDIFF(MINUTE, opened_at, resolved_at) AS resolution_minutes
    FROM dbo.Incidents
    WHERE resolved_at IS NOT NULL
)
SELECT
    AVG(resolution_minutes) AS average_resolution_minutes
FROM ResolutionTimes;

WITH ResolutionTimes AS
(
    SELECT
        DATEDIFF(MINUTE, opened_at, resolved_at) AS resolution_minutes
    FROM dbo.Incidents
    WHERE resolved_at IS NOT NULL
)
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP
        (ORDER BY resolution_minutes) OVER () AS median_resolution_minutes
FROM ResolutionTimes;

WITH ResolutionGroups AS
(
    SELECT
        CASE
            WHEN DATEDIFF(DAY, opened_at, resolved_at) <= 1
                THEN '0-1 days'
            WHEN DATEDIFF(DAY, opened_at, resolved_at) <= 7
                THEN '2-7 days'
            WHEN DATEDIFF(DAY, opened_at, resolved_at) <= 30
                THEN '8-30 days'
            WHEN DATEDIFF(DAY, opened_at, resolved_at) <= 90
                THEN '31-90 days'
            ELSE '90+ days'
        END AS resolution_range
    FROM dbo.Incidents
    WHERE resolved_at IS NOT NULL
)
SELECT
    resolution_range,
    COUNT(*) AS incident_count
FROM ResolutionGroups
GROUP BY resolution_range
ORDER BY
    CASE resolution_range
        WHEN '0-1 days' THEN 1
        WHEN '2-7 days' THEN 2
        WHEN '8-30 days' THEN 3
        WHEN '31-90 days' THEN 4
        WHEN '90+ days' THEN 5
    END;

SELECT TOP 10
    number,
    category,
    priority,
    state,
    opened_at,
    DATEDIFF(DAY, opened_at, GETDATE()) AS days_open
FROM dbo.Incidents
WHERE state NOT IN ('Closed', 'Resolved')
ORDER BY days_open DESC;

SELECT
    priority,
    COUNT(*) AS unresolved_incidents
FROM dbo.Incidents
WHERE state NOT IN ('Closed', 'Resolved')
GROUP BY priority
ORDER BY unresolved_incidents DESC;
