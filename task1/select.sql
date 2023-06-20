-- Получить опросы
SELECT
    *
FROM
    survey;

-- Получаем кол-во ответов на вопросы опроса с id=1 
SELECT
    q.serial_number AS number,
    COUNT(a.value) AS count
FROM
    answer AS a
    RIGHT JOIN question AS q
        ON q.id = a.question_id
            AND q.survey_id = 1
GROUP BY
    number
ORDER BY 
    number;

-- Получить ответы респондентов на вопрос с id=2 опроса с id=1 в алфавитном порядке
SELECT
    r.telegram_id AS respondent, 
    a.value AS value
FROM
    answer AS a
    INNER JOIN respondent AS r
        ON r.id = a.respondent_id
    INNER JOIN question AS q 
        ON q.id = a.question_id
            AND q.id = 2
            AND q.survey_id = 1
ORDER BY value;

-- Получить количество созданных опросов пользователями бота, отсортированных по убыванию
SELECT 
    CONCAT(u.last_name, ' ', u.first_name, ' ', u.patronymic) AS FIO,
    COUNT(s.id) AS count
FROM user_data AS u
    LEFT JOIN survey s
        ON u.id = s.user_data_id
GROUP BY FIO
ORDER BY count DESC;
