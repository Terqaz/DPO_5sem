-- Обновить название вопроса в опросе
UPDATE
    question q
SET
    title = 'Хотите ли вы открыть свое дело, стать предпринимателем?'
FROM
    survey s
WHERE
    s.id = q.survey_id
    AND s.title = 'Пора предпринимать? Мониторинг 2018–2022'
    AND q.title = 'Скажите, Вы хотите или не хотите открыть свое дело, стать предпринимателем?';

-- Восстановить
UPDATE
    question q
SET
    title = 'Скажите, Вы хотите или не хотите открыть свое дело, стать предпринимателем?'
FROM
    survey s
WHERE
    s.id = q.survey_id
    AND s.title = 'Пора предпринимать? Мониторинг 2018–2022'
    AND q.title = 'Хотите ли вы открыть свое дело, стать предпринимателем?';

-- Проверить
SELECT * from question q
JOIN survey s
    ON s.id = q.survey_id
        AND s.title = 'Пора предпринимать? Мониторинг 2018–2022';