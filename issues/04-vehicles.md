# Vehicles: Luke pilots a snowspeeder and an Imperial speeder bike

Estimate: 20 minutes

The first related data, and the one with the fewest quirks. It sets the
pattern every later panel follows: records link straight to each other in both
directions, so `luke.vehicles.first.pilots` reads as it should. The data's
own capitalization stands ("t-47 airspeeder", "Incom corporation").

Number keys count only the panels that take focus, in reading order: `1`
Search, in the title row, then `2` Characters. A panel that takes focus later
gets the next number, so these never move. Vehicles takes none: no character
pilots more than two, which always fit, so it has nothing to scroll.

- [x] Luke's vehicles: Snowspeeder and Imperial Speeder Bike, with model, manufacturer, class, crew, and passengers
- [x] A vehicle's pilots link back, and both directions agree
- [x] Passengers `"unknown"`
- [x] Any unknown field reads dimmed (the Emergency Firespeeder's manufacturer)
- [x] A character who pilots no vehicle sees an empty state
- [x] Refactor: extract one module per panel, with snapshots unchanged. (Attributes, Species, and Homeworld become View-only parts of Selected Character in issues 8 to 10, which create them.)
