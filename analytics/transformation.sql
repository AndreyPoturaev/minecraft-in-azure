WITH 
SessionInfo AS (  
    SELECT
        TS, 'START' as EVENT, SUBSTRING(MESSAGE, 0, REGEXMATCH(MESSAGE, '[ ]*joined the game')) as PLAYER
    FROM
        logslob
    TIMESTAMP BY TS
    WHERE REGEXMATCH(MESSAGE, 'joined the game') > 0
UNION
    SELECT
        TS, 'END' as EVENT, SUBSTRING(MESSAGE, 0, REGEXMATCH(MESSAGE, '[ ]*left the game')) as PLAYER
    FROM
        logslob
    TIMESTAMP BY TS
    WHERE REGEXMATCH(MESSAGE, 'left the game') > 0
),
RawLogs AS (
    SELECT
        TS, LEVEL, MESSAGE
    FROM
        logslob
    TIMESTAMP BY TS
)

SELECT * INTO sbq from SessionInfo;
SELECT * INTO pbi from RawLogs;
