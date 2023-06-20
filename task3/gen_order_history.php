<?php

use \DateTime as DateTime;
use \DateTimeImmutable as DateTimeImmutable;

/**
 * Генерация таблицы заказа и истории заказа
 * Все-таки решил написать :)
 */
class MyGenerator
{
    // Настройки
    const ORDER_STATUSES = [
        1 => 'Создан',
        2 => 'Оформлен',
        3 => 'Собран',
        4 => 'В пути',
        5 => 'Доставлен',
        6 => 'Отменен',
        7 => 'Выполнен', // Выполнен обязательно последний
    ];

    const MAX_CUSTOMER_ID = 7;
    const MAX_MANAGER_ID = 20;
    const LAST_CUSTOMER_CREATED_DATE = '2000-01-07 17:00:00';
    const LAST_ORDER_CREATE_DATE = '2022-03-17 21:13:05';

    private array $utmSources = [
        'quas',
        'sunt',
        'ipsa',
        'autem',
        'earum',
        'esse',
        'eos',
        'nam',
        'nostrum',
        'necessitatibus',
        'minima',
        'est',
        'enim',
        'quibusdam',
        'ipsam',
        'sed',
        'amet',
        'sed',
        'aut',
        'tempora',
        'quam',
        'porro',
        'velit',
        'consequatur',
        'nisi',
        'itaque'
    ];

    // поддерживаются эти поля
    const MANAGER_ID_FIELD = 'manager_id';
    const STATUS_ID_FIELD = 'status_id';
    const IS_PAID_FIELD = 'is_paid';
    const TOTAL_SUM_FIELD = 'total_sum';

    const ORDER_CHANGEABLE_FIELDS = [
        self::MANAGER_ID_FIELD,
        self::STATUS_ID_FIELD,
        self::IS_PAID_FIELD,
        self::TOTAL_SUM_FIELD,
    ];

    // конец Настройки

    const DATE_FORMAT = 'Y-m-d H:i:s';

    private $completedStatusId;

    private $orderId = 1;
    private $changeId = 1;
    private $startChangesDate;

    public function __construct()
    {
        $this->utmSources = array_unique($this->utmSources);
        $this->completedStatusId = array_key_last(self::ORDER_STATUSES);
        $this->startChangesDate = DateTime::createFromFormat(self::DATE_FORMAT, self::LAST_ORDER_CREATE_DATE);
    }

    public function createOrders(int $count): array
    {
        $orders = [];
        for ($i = 0; $i < $count; $i++) {
            $orders[] = $this->createOrder();
        }

        return $orders;
    }

    private function createOrder(): array
    {
        return [
            'id' => $this->orderId++,
            'created_at' => self::randomDate(self::LAST_CUSTOMER_CREATED_DATE, self::LAST_ORDER_CREATE_DATE),
            'customer_id' => random_int(1, self::MAX_CUSTOMER_ID),
            'manager_id' => random_int(1, self::MAX_MANAGER_ID),
            'status_id' => 1, // Сначала в статусе Создан
            'is_paid' => false,
            'total_sum' => random_int(100, 100000),
            'utm_source' => self::randomArrayElement($this->utmSources),
        ];
    }

    public function changeOrders(int $count, array &$orders): array
    {
        $changes = [];
        for ($i = 0; $i < $count; $i++) {
            $change = null;

            while ($change === null) {
                $randI = random_int(0, count($orders) - 1);
                $change = $this->changeOrder($orders[$randI]);
                
            }
            [$order, $change] = $change;
            $orders[$randI] = $order;
            
            $changes[] = $change;
        }

        return $changes;
    }

    private function changeOrder(array $order): ?array
    {
        $changeField = self::randomArrayElement(self::ORDER_CHANGEABLE_FIELDS);

        if ($changeField === self::STATUS_ID_FIELD) {
            if ($order[self::STATUS_ID_FIELD] === $this->completedStatusId) {
                return null;
            }

            $oldStatusId = $order[self::STATUS_ID_FIELD];
            $newStatusId = $oldStatusId + random_int(1, $this->completedStatusId - $oldStatusId);

            if ($newStatusId >= $this->completedStatusId && !$order['is_paid']) {
                return null; // не удалось сгенерить изменение
            }

            $order[self::STATUS_ID_FIELD] = $newStatusId;

            return [$order, $this->createChange($order['id'], $changeField, $oldStatusId, $newStatusId)];
            
        } else if ($changeField === self::MANAGER_ID_FIELD) {
            $oldManagerId = $order[self::MANAGER_ID_FIELD];
            $newManagerId = random_int(1, self::MAX_MANAGER_ID);

            $order[self::MANAGER_ID_FIELD] = $newManagerId;

            return [$order, $this->createChange($order['id'], $changeField, $oldManagerId, $newManagerId)];

        } else if ($changeField === self::IS_PAID_FIELD) {
            
            if (!$order['is_paid']) {
                $order['is_paid'] = true;
                return [$order, $this->createChange($order['id'], $changeField, false, true)];
            } else {
                return null;
            }

            
        } else if ($changeField === self::TOTAL_SUM_FIELD) {
            $oldValue = $order[self::TOTAL_SUM_FIELD];
            $newValue = random_int(100, 100000);

            $order[self::TOTAL_SUM_FIELD] = $newValue;

            return [$order, $this->createChange($order['id'], $changeField, $oldValue, $newValue)];
        } else {
            throw new Exception("error");
        }
    }

    private function createChange(int $orderId, string $field, mixed $oldValue, mixed $newValue): array
    {
        if (gettype($oldValue) === 'boolean') {
            $oldValue = $oldValue ? 'true' : 'false';
        }

        if (gettype($newValue) === 'boolean') {
            $newValue = $newValue ? 'true' : 'false';
        }

        return [
            'id' => $this->changeId++,
            'order_id' => $orderId,
            'created_at' => $this->nextChangeDate(),
            'field_name' => $field,
            'old_value' => (string) $oldValue,
            'new_value' => (string) $newValue,
        ];
    }

    public function createInsertValues(array $data): string
    {
        $formattedData = [];

        foreach ($data as $item) {
            $formattedItems = [];

            foreach ($item as $value) {
                if (gettype($value) === 'boolean') {
                    $value = $value ? 'true' : 'false';
                }
                
                if (gettype($value) === 'string') {
                    $value = "'" . $value . "'";
                }

                $formattedItems[] = $value;
                
            }
            $formattedData[] = '(' . implode(', ', $formattedItems) .')';
        }

        return implode(",\n", $formattedData) . ";\n";
    }

    private static function randomArrayElement(array $a): mixed
    {
        return $a[random_int(0, count($a) - 1)];
    }

    private static function randomDate(string $from, string $to): string
    {
        $fromTs = DateTime::createFromFormat(self::DATE_FORMAT, $from)->getTimestamp();
        $toTs = DateTime::createFromFormat(self::DATE_FORMAT, $to)->getTimestamp();

        return (new DateTimeImmutable())->setTimestamp(random_int($fromTs, $toTs))->format(self::DATE_FORMAT);
    }

    private function nextChangeDate(): string
    {
        $interval = 'P' . random_int(0, 5) . 'DT' . random_int(0, 24) . 'H' . random_int(0, 60) . 'M' . random_int(0, 60) . 'S';
        $this->startChangesDate->add(new DateInterval($interval));
        return $this->startChangesDate->format(self::DATE_FORMAT);
    }
}

$generator = new MyGenerator();

$orders = $generator->createOrders(25);
$changes = $generator->changeOrders(100, $orders);
echo "INSERT INTO public.\"order\"(id, created_at, customer_id, manager_id, status_id, is_paid, total_sum, utm_source)\nVALUES\n";
echo $generator->createInsertValues($orders);
echo "\n\n";

echo "INSERT INTO public.order_history(id, order_id, created_at, field_name, old_value, new_value)\nVALUES\n";
echo $generator->createInsertValues($changes);
