# Локальный Lakehouse — TPC-H Q3

**Автор:** Уваров Максим Сергеевич  
**Вариант:** 1 — Shipping Priority  
**Масштаб:** sf1

## Состав

- **Silo** — S3-совместимое объектное хранилище.
- **PostgreSQL** — хранение состояния каталога Lakekeeper.
- **Lakekeeper** — Iceberg REST Catalog для метаданных таблиц.
- **Trino** — SQL-движок для загрузки, преобразований и аналитики.
- **Superset** — дополнительный BI-инструмент, запущенный в Docker.
- **DBeaver** — SQL-клиент для Windows.

Поток обработки:

`tpch.sf1 → iceberg.bronze → iceberg.silver.order_lines → iceberg.gold.shipping_priority`

## Файлы проекта

- Основные Compose-файлы — развёртывание Lakehouse.
- `trino/` — настройки Trino и каталогов.
- `sql/` — SQL-скрипты загрузки, преобразований, проверок и экспериментов.
- `compose.bi.yaml` — конфигурация запуска Superset.
- `bi/Dockerfile` — сборка Superset с драйвером Trino.
- `bi/superset_config.py` — локальные настройки Superset.
- `docs/images/` — скриншоты, подтверждающие работу сервисов.
- `отчет.md` — подробный отчёт по практической работе.

## Запуск уже инициализированного окружения

Команды выполняются из каталога проекта:

```powershell
docker compose start
docker compose -f compose.bi.yaml up -d superset
```

Проверка состояния:

```powershell
docker compose ps -a
docker compose -f compose.bi.yaml ps -a
docker compose exec trino trino --user student --execute "SELECT count(*) FROM iceberg.gold.shipping_priority"
```

Последний запрос должен вернуть `10`.

Для остановки сервисов:

```powershell
docker compose -f compose.bi.yaml stop
docker compose stop
```

При остановке контейнеров тома с данными сохраняются.

## Развёртывание с нуля

1. Установить Docker Desktop с Linux-контейнерами и WSL2.
2. Подготовить конфигурационные файлы и локальные значения переменных окружения.
3. Запустить Silo, PostgreSQL и Lakekeeper и дождаться успешного выполнения миграции каталога.
4. Создать бакет `lakehouse`.
5. Настроить Lakekeeper и зарегистрировать warehouse `lakehouse` с endpoint `http://silo:9000`, регионом `us-east-1`, включённым path-style access и префиксом `warehouse`.
6. Запустить Trino с каталогами `tpch` и `iceberg`.
7. Выполнить SQL-скрипты создания Bronze, проверки Bronze, формирования и проверки Silver, создания Gold и сравнения результата с исходным запросом Q3.
8. Собрать Superset, выполнить `superset db upgrade`, создать администратора, запустить `superset init` и поднять веб-сервис.
9. Добавить подключение `trino://student@trino:8080/iceberg/bronze` и проверить таблицы Bronze через SQL Lab.

В существующем окружении warehouse и таблицы хранятся в Docker volumes. Через Git эти данные автоматически не переносятся. При новом развёртывании настройку и SQL-инициализацию нужно выполнить повторно; ID warehouse и снапшотов будут отличаться.

## Адреса сервисов

| Сервис | Адрес |
|---|---|
| Trino | [http://localhost:8080](http://localhost:8080) |
| Silo Console | [http://localhost:9001](http://localhost:9001) |
| Lakekeeper | [http://localhost:8181](http://localhost:8181) |
| Superset | [http://localhost:8088](http://localhost:8088) |

## Основные результаты

| Формат | Кодек | Размер Bronze, МБ | Запись трёх таблиц, с | Медиана Q3, с |
|---|---|---:|---:|---:|
| Parquet | ZSTD | 48,656 | 5,181 | 1,087 |
| Parquet | GZIP | 48,816 | 8,452 | 1,166 |
| ORC | ZSTD | 54,390 | 6,077 | 0,958 |

Время записи — сумма отдельных измерений создания трёх таблиц. Время Q3 — медиана пяти запусков после одного прогревочного выполнения; использована метрика `Execution` из `EXPLAIN ANALYZE`.

**Примечание:** значения времени в этой таблице являются оценочными и требуют замены фактическими результатами запуска на целевом компьютере. Размеры файлов приведены из отчёта и не пересчитывались.
