# Starships: Luke pilots an X-wing and an Imperial shuttle

Estimate: 15 minutes

Related data again, following the Vehicles pattern, with the first numeric
quirks among the related records.

- [ ] Luke's X-wing and Imperial shuttle, with model, manufacturer, class, crew, and passengers, drawn with Vehicles' `ValueSpan` and `ValuePair`, moved into a `View`-only module both panels share
- [ ] A starship's pilots link back, and both directions agree
- [ ] Crew and passengers with thousands separators (`"47,060"`, `"843,342"`), a range (`"30-165"`), and `"unknown"`
- [ ] A character who pilots no starship sees an empty state
- [ ] Obi-Wan's five starships overflow the panel at 120×40: decide between a taller panel and showing less, since Starships takes no focus to scroll
