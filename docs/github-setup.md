# Подключение GitHub

> Сейчас `origin` указывает на **GitLab** (`surfstudio.gitlab.yandexcloud.net`).
> GitHub подключается **дополнительным remote** — GitLab можно оставить.

## 1. Создать репозиторий на GitHub

1. [github.com/new](https://github.com/new) → имя, например `summer-school-2026`
2. **Не** добавляйте README / .gitignore (они уже есть локально)

## 2. Добавить remote

Замените `YOUR_USER` на свой логин GitHub (для этого проекта: **Iren0708/SurfProjctClimbing**):

```bash
git remote add github https://github.com/Iren0708/SurfProjctClimbing.git
```

Проверка:

```bash
git remote -v
```

Ожидаемый результат:

```
github   https://github.com/Iren0708/SurfProjctClimbing.git (fetch)
github   https://github.com/Iren0708/SurfProjctClimbing.git (push)
origin   https://surfstudio.gitlab.yandexcloud.net/kruckih/summer-school-2026.git (fetch)
origin   https://surfstudio.gitlab.yandexcloud.net/kruckih/summer-school-2026.git (push)
```

## 3. Первый push на GitHub

```bash
git push -u github main
```

Дальше — по необходимости:

```bash
git push github main          # только GitHub
git push origin main          # только GitLab
git push github main && git push origin main   # оба
```

## 4. GitHub Actions (CI)

Workflow: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

Запускается автоматически при push / PR в `main` или `develop`:

- сборка и тесты backend (Gradle + PostgreSQL)
- сборка Docker-образа API

Статус: вкладка **Actions** в репозитории на GitHub.

## 5. SSH вместо HTTPS (опционально)

```bash
git remote set-url github git@github.com:YOUR_USER/summer-school-2026.git
```

Нужен [SSH-ключ в GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

## 6. Сделать GitHub основным remote (опционально)

```bash
git remote rename origin gitlab
git remote rename github origin
git push -u origin main
```
