# Vehicles: Luke pilots a snowspeeder and an Imperial speeder bike

Estimate: 20 minutes

The first related data, and the one with the fewest quirks. It sets the
pattern every later panel follows: records link to each other by ID in both
directions, and any reference resolves the same way through the domain
model. The data's own capitalization stands ("t-47 airspeeder", "Incom
corporation").

Number keys follow the wireframe, left to right: `1` Characters, `2`
Selected Character, `3` Search, `4` Films, `5` Starships, `6` Vehicles. Each
panel's story binds its own key.

- [ ] Luke's vehicles resolve by ID: Snowspeeder and Imperial Speeder Bike, with model, manufacturer, class, crew, and passengers
- [ ] A vehicle's pilots link back by ID, and both directions agree
- [ ] Passengers `"unknown"`
- [ ] A character who pilots no vehicle sees an empty state
- [ ] `6`, Tab, and Shift-Tab focus Vehicles, which scrolls with the list's keys
- [ ] Refactor: extract one module per panel, with snapshots unchanged. Attributes, Species, and Homeworld become View-only parts of Selected Character.
