# FollowThrough: Because "Fixed" Should Mean Verified

FollowThrough helps families keep track of care concerns for someone in a nursing home or assisted living facility. When staff say they've fixed a problem, the family records what they said and marks the concern **Reported fixed**. On the next visit, a different relative checks the fix and records what they saw as part of logging that visit. The concern becomes **Verified** only when a relative confirms the fix.
 
**Live app:** https://followthrough-team-d64d6d9bc835.herokuapp.com/

## Team members

| Name | UNI |
| --- | --- |
| Zoe Li | wl3019 |
| Silin Jiang | sj3484 |
| Tianming Hao | th3016 |
| Jessica Song | ys3815 |

## Try it

The quickest way is **Try a demo family** on the sign in page. It needs no account. You get your own copy of Linda Chen's family as a guest, with a recheck waiting for you, and the copy is deleted when you leave, so other visitors' clicks never change what you see.

You can also sign in with one of the shared demo accounts. All three are in Linda Chen's family. The password for each is `password123`.

| Account | Role | What to try |
| --- | --- | --- |
| amy@example.com | Relative | The home page shows a recheck assigned to Amy. Choose **Log a visit**, check the fix against the Signal Card, and save the visit with what she saw. |
| david@example.com | Organizer | The Family page shows the invite code and lets David manage who has access. David opened the water cup concern, so he can't recheck it. |
| grace@example.com | Relative | Open the Meeting brief to compare what staff reported with what the family saw. |

## Features

Iteration 1 built the core workflow. Iteration 2 adds accounts, the shared family space, recheck assignments, visit logs, and the meeting brief.

| Feature | What a user can do | User stories |
| --- | --- | --- |
| Accounts | Sign up, sign in and out. Every page needs an account. | [6_accounts](features/6_accounts.feature) |
| Family space | Create a profile and become its organizer. Invite relatives with a code. Only members can see the profile. The organizer can update the facility and room and remove a relative's access, which opens their waiting rechecks to the rest of the family. | [1_family_profile](features/1_family_profile.feature), [7_family_space](features/7_family_space.feature) |
| Signal Card | Add, edit, remove and search signals. Each one shows who last updated it. | [2_signal_card](features/2_signal_card.feature) |
| Demo family | **Try a demo family** on the sign in page signs a visitor in as a guest with a private copy of the sample family. Leaving or signing out deletes it. Guests can't join real families and real users can't join demo ones. | [11_demo](features/11_demo.feature) |
| Visit log | The one thing a visitor does. Record how the resident seemed, which signals you noticed, and notes, and check any fixes staff reported on the same form. Open a concern from a visit. | [10_visit_log](features/10_visit_log.feature) |
| Concerns | Record a problem and what "fixed" would look like. A progress bar shows where it stands. | [3_open_concern](features/3_open_concern.feature) |
| Staff responses | Record what staff said. The concern becomes Reported fixed and the recheck is assigned to another relative. | [4_staff_response](features/4_staff_response.feature), [8_recheck_assignment](features/8_recheck_assignment.feature) |
| Rechecks | The assigned relative sees the recheck first on their home page and records it while logging a visit, using the Signal Card checklist. Each recheck links back to the visit it came from. If plans change, any relative can reassign the recheck or open it to anyone in the family. | [5_recheck](features/5_recheck.feature), [8_recheck_assignment](features/8_recheck_assignment.feature), [10_visit_log](features/10_visit_log.feature) |
| Meeting brief | Pick a period and see how many fixes staff reported, how many the family verified, and each concern side by side. Print it or save it as a PDF. | [9_meeting_brief](features/9_meeting_brief.feature) |

### How the core workflow fits together

```mermaid
sequenceDiagram
    actor David as David (son)
    actor Staff as Nursing staff
    actor Amy as Amy (daughter)
    participant App as FollowThrough (Rails app)
    participant DB as Database

    Note over David,DB: Tuesday visit
    David->>+App: POST care_concerns (problem, what fixed looks like)
    App->>DB: Save concern, opened by David, status open
    App-->>-David: Concern page, status Open
    Staff->>David: Says the problem is fixed
    David->>+App: POST staff_responses (who, what, when, recheck by Amy)
    App->>DB: Save response, status reported_fixed, assigned to Amy
    App-->>-David: Status Reported fixed, recheck assigned to Amy

    opt David tries to recheck his own concern
        David->>+App: POST visits (signed in as David, result for his concern)
        App-->>-David: 422, must be a different relative
    end

    Note over David,DB: Sunday visit
    Amy->>+App: GET home page
    App->>DB: Load rechecks assigned to Amy
    App-->>-Amy: Your rechecks, Water cup out of reach, Log a visit
    Amy->>+App: GET new visit page
    App-->>-Amy: Visit form with the fix to check and the Signal Card checklist
    Amy->>+App: POST visits (mood, signals, notes, result for the water cup)
    alt The fix held
        App->>DB: Save visit and recheck together, status verified
        App-->>Amy: Visit saved with 1 recheck, status Verified
    else The fix did not hold
        App->>DB: Save visit and recheck together, status not_verified
        App-->>Amy: Visit saved, concern back to Waiting for staff
    end
    deactivate App
```

Each step is covered by Cucumber: opening a concern (`3_open_concern.feature`), recording staff responses and assigning the recheck (`4_staff_response.feature`, `8_recheck_assignment.feature`), and checking fixes while logging a visit (`5_recheck.feature`). The error case is the scenario "The relative who opened the concern cannot record its recheck" in `8_recheck_assignment.feature`.

### Changes after iteration 2 feedback

- **One action for a visitor.** Logging a visit and recording a recheck used to be two separate forms, so it was unclear which one a visitor should use. A visitor now only logs a visit. The visit form lists the fixes they can check (their own assignments first) with the Signal Card checklist, and saving the visit saves those rechecks with it. The concern page and the home page point to **Log a visit** instead of a separate recheck form, and each recheck links back to its visit.
- **Gentler wording for access.** The organizer now chooses **Remove access** instead of removing someone from the family, and the message says the person no longer has access to the family space and can rejoin with the invite code. The browser asks the organizer to confirm before access is removed, so a mistaken click can be cancelled.

### UI sketches

Zoe Li drew our UI sketches by hand. They are in [docs/ui-sketches.pdf](docs/ui-sketches.pdf).

| Sketch | Status |
| --- | --- |
| Signal Card | Implemented in iteration 1, search and "updated by" added in iteration 2 |
| Concern detail and recheck | Implemented in iteration 1, progress bar and recheck assignment added in iteration 2, rechecks recorded from the visit log after feedback |
| Family home (my rechecks first, open concerns) | Implemented in iteration 2 |
| Family space (members, roles, invites) | Implemented in iteration 2 with invite codes |
| Log a visit | Implemented in iteration 2, rechecks moved onto this form after feedback |
| Care plan meeting brief | Implemented in iteration 2 |

Photo uploads from the sketches are left out because Heroku does not keep uploaded files.

### Concern status

```
open ──staff response──> reported_fixed ──recheck──> verified ──recheck──> recurred
                               │
                               └──recheck──> not_verified
```

A new staff response moves an **Open**, **Not verified** or **Recurred** concern to **Reported fixed**. Once a fix is **Verified**, a recheck can only record that the problem came back. The relative who opened a concern can't record its recheck, and the recheck can only be assigned, or reassigned, to another member of the family.

See the rules in [CareConcern](app/models/care_concern.rb), [StaffResponse](app/models/staff_response.rb), [Recheck](app/models/recheck.rb) and [MeetingBrief](app/models/meeting_brief.rb), and the [model specs](spec/models/).

## Run locally

Install Ruby 3.3.8 and Bundler. You can use rbenv as in `hw-setup`. The app uses Rails 7.2 and SQLite locally.

```bash
git clone https://github.com/Zoeooeo/followthrough.git
cd followthrough
bundle config set --local without production  # skip the pg gem locally
bin/setup                                     # install gems, prepare databases, load sample data
bin/rails server
```

Open [localhost:3000](http://localhost:3000) and sign in with a demo account from [Try it](#try-it).

### Demo data

All names in the sample data and tests are fictional and used only for this class demo. This includes the resident (Linda Chen), her family members (David, Amy, Grace), the staff members, and the care facility (Greenview Nursing Home). Any resemblance to real people or facilities is coincidental. **Try a demo family** copies the same fictional story for each guest.

## Tests

```bash
bin/rails db:test:prepare # First setup or after a new migration
bundle exec cucumber
bundle exec rspec
```

Cucumber and Capybara run through the family workflows. RSpec covers models and HTTP requests, including who can see and change each family's records. SimpleCov combines both runs in `coverage/index.html`.

## Deploy to Heroku

Heroku uses PostgreSQL. Before deploying, generate and commit `Gemfile.lock` with the Linux platform.

```bash
bundle lock --add-platform x86_64-linux --add-platform ruby
git add Gemfile.lock
git commit -m "Update Gemfile.lock for Heroku"
```

```bash
heroku login
heroku create
heroku addons:create heroku-postgresql:essential-0
git push heroku main
heroku run bin/rails db:seed
heroku open
```

The release command in [Procfile](Procfile) runs the migrations. If Heroku asks for `SECRET_KEY_BASE`, run `heroku config:set SECRET_KEY_BASE="$(bin/rails secret)"`.

Demo families are deleted when the guest leaves or signs out. Guests who just close the tab leave theirs behind, so delete demo accounts older than a day with `heroku run bin/rails demo:clean_up`, or add that command to Heroku Scheduler to run daily.

### Updating an existing database

This section is only about the database. The full list of what each iteration added is under [Features](#features).

**From iteration 1.** Iteration 2 replaced typed names with accounts, so concerns and rechecks saved in iteration 1 can't be carried over. Reset the database before deploying, then load the demo data again.

```bash
bin/rails db:reset                                              # local
heroku pg:reset DATABASE_URL --confirm YOUR-APP-NAME            # Heroku, before git push heroku main
heroku run bin/rails db:seed -a YOUR-APP-NAME                   # Heroku, after the push
```

**Within iteration 2.** Later changes, such as linking each recheck to the visit it was recorded on and marking demo families, only add columns. Existing data is kept. Run `bin/rails db:migrate` locally. On Heroku the release step runs the migrations during `git push heroku main`.

## Project structure

```
app/models/          User, Membership, Resident, SignalItem, Visit, CareConcern, StaffResponse, Recheck, MeetingBrief,
                     DemoFamily (builds and deletes each guest's sample family)
app/controllers/     Resource controllers. Family records are nested under /residents/:resident_id
                     and only load for members of that family.
app/views/           Server-rendered pages, no JavaScript required
db/migrate/          Table definitions
features/            Cucumber user stories and step definitions
spec/models/         Validation, permission and status-rule tests
spec/requests/       HTTP request tests, including sign-in and family access
lib/tasks/demo.rake  bin/rails demo:clean_up deletes demo families older than a day
```

## References

- Kevin Hakanson. "Sequence Diagrams enrich your understanding of distributed architectures." *AWS Architecture Blog*, August 19, 2022. https://aws.amazon.com/blogs/architecture/sequence-diagrams-enrich-your-understanding-of-distributed-architectures/
