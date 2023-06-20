-- Удалить пользователя Репин Изяслав Владимирович
DELETE FROM 
    user_data u 
WHERE 
    u.last_name = 'Репин' 
    AND u.first_name = 'Изяслав'
    AND u.patronymic = 'Владимирович';

-- Восстановить
INSERT INTO
    user_data (last_name, first_name, patronymic, email, password_hash)
VALUES
    (
        'Репин',
        'Изяслав',
        'Владимирович',
        'email5@some.site',
        's7a80dgtfpas89tgaso87fs'
    );