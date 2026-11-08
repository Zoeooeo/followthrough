# FollowThrough: Because "Fixed" Should Mean Verified

FollowThrough is a web app for families whose loved one lives in a nursing home
or assisted living facility. When staff say a care problem is fixed, the family
keeps that as **"Reported fixed"**, not resolved. On the next visit, a
**different relative** checks it against the resident's **Signal Card** and
records whether it was **Verified**, **Not verified**, or **Recurred**.

- **Heroku:** `https://YOUR-APP-NAME.herokuapp.com` (replace after deploying)
- **GitHub:** `https://github.com/YOUR-ACCOUNT/followthrough`

## Team members

| Name | UNI |
|---|---|
| `Zoe Li` | `UNI:` wl3019 |
| `Silin Jiang` | `UNI:` sj3484 |
| `Tianming Hao` | `UNI:` th3016 |
| `Jessica Song` | `UNI:` ys3815 |

## Iteration 1 scope

The most basic features of the product, end to end:

| Feature | What a user can do | User stories |
|---|---|---|
| Shared family profile | Create a profile for a loved one, see all profiles | `features/1_family_profile.feature` |
| Signal Card | Add, edit and remove how she shows a need and what to check | `features/2_signal_card.feature` |
| Concerns | Open a concern with a "what fixed looks like" goal, linked to a signal | `features/3_open_concern.feature` |
| Staff responses | Record who said what and when, which marks the concern Reported fixed | `features/4_staff_response.feature` |
| Rechecks | A different relative checks with the Signal Card checklist and records the result | `features/5_recheck.feature` |

### Concern status rules

```
open ──staff response──> reported_fixed ──recheck──> verified ──recheck──> recurred
                               │
                               └──recheck──> not_verified
```

- A staff response can be recorded while a concern is **Open**, **Not verified** or **Recurred**. It always moves the concern to **Reported fixed**.
- From **Reported fixed**, a recheck can be **Verified** or **Not verified**.
- From **Verified**, a recheck can only be **Recurred** (the problem came back).
- The person who checks must be **someone other than the relative who opened the concern**.

These rules live in `app/models/care_concern.rb`, `app/models/staff_response.rb` and `app/models/recheck.rb`, and are covered by the model specs.

Planned for iteration 2: sign in, inviting relatives with roles, assigning
rechecks to the next visitor, a family dashboard, and the one-page meeting brief.

## Tech stack

- Ruby 3.3.8, Rails 7.2
- SQLite in development and test, PostgreSQL on Heroku
- Cucumber + Capybara for user stories, RSpec for unit and request tests, SimpleCov for coverage

## Run it locally

Requires Ruby 3.3.8 (for example through rbenv, as in hw-setup) and Bundler.

```bash
git clone https://github.com/YOUR-ACCOUNT/followthrough.git
cd followthrough
bundle config set --local without production   # skip the pg gem locally
bin/setup                                       # installs gems, creates databases, loads sample data
bin/rails server
```

Open http://localhost:3000. The sample data includes Linda Chen with two signals,
one concern that is Reported fixed (ready for a recheck) and one that is Open.

## Run the tests

```bash
bin/rails db:test:prepare     # only needed the first time or after a new migration
bundle exec cucumber          # user stories
bundle exec rspec             # model and request specs
```

Both commands write to the same coverage report. Run both, then open
`coverage/index.html` to see the combined coverage.

## Deploy to Heroku

```bash
heroku login
heroku create YOUR-APP-NAME
heroku addons:create heroku-postgresql:essential-0
git push heroku main          # the release phase in Procfile runs db:migrate
heroku run bin/rails db:seed  # optional demo data
heroku open
```

`Gemfile.lock` must be committed. If you created it on a Mac, add the Linux
platform Heroku builds on before pushing:

```bash
bundle lock --add-platform x86_64-linux
git add Gemfile.lock && git commit -m "Add Linux platform for Heroku"
```

If Heroku reports a missing `SECRET_KEY_BASE`, set one:

```bash
heroku config:set SECRET_KEY_BASE=$(bin/rails secret)
```

## Project structure

```
app/models/          Resident, SignalItem, CareConcern, StaffResponse, Recheck
app/controllers/     One controller per resource, nested under residents
app/views/           Server-rendered pages, no JavaScript required
db/migrate/          Table definitions
features/            Cucumber user stories and step definitions
spec/models/         Validation and status-rule tests
spec/requests/       Controller behaviour through HTTP requests
```
