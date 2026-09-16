# Changelog

## [1.1.0](https://github.com/soc-analyst/soc-analyst/compare/v1.0.0...v1.1.0) (2025-09-16)


### Features

* **dashboards:** voeg KPI single-value panels toe aan alle dashboards ([ac0c45a](https://github.com/soc-analyst/soc-analyst/commit/ac0c45a))
* **dashboards:** voeg time range pickers toe aan alle dashboards ([1f35cf0](https://github.com/soc-analyst/soc-analyst/commit/1f35cf0))
* **alerts:** voeg 10 detection rules toe voor security monitoring ([e9d9bbf](https://github.com/soc-analyst/soc-analyst/commit/e9d9bbf))
* **filters:** voeg input fields toe voor filtering ([6a6c9e4](https://github.com/soc-analyst/soc-analyst/commit/6a6c9e4))
* **lookups:** voeg 5 lookup tables toe voor threat intel ([6a6c9e4](https://github.com/soc-analyst/soc-analyst/commit/6a6c9e4))
* **mitre:** voeg MITRE ATT&CK dashboard toe ([6a6c9e4](https://github.com/soc-analyst/soc-analyst/commit/6a6c9e4))
* **drilldown:** voeg investigation dashboard toe ([6a6c9e4](https://github.com/soc-analyst/soc-analyst/commit/6a6c9e4))
* **makefile:** voeg Docker support en remote deploy toe ([30b8b7d](https://github.com/soc-analyst/soc-analyst/commit/30b8b7d))
* **docs:** voeg LOOKUPS.md toe ([6a6e4b1](https://github.com/soc-analyst/soc-analyst/commit/6a6e4b1))


### Bug Fixes

* **nav:** navigation menu toont alleen overview dashboard ([fffa205](https://github.com/soc-analyst/soc-analyst/commit/fffa205))
* **makefile:** gebruik .spl extensie in plaats van .splunk ([bd54db6](https://github.com/soc-analyst/soc-analyst/commit/bd54db6))
* **makefile:** build .spl met correcte directory structuur ([243b589](https://github.com/soc-analyst/soc-analyst/commit/243b589))
* **dashboards:** voeg version="1.1" toe aan alle dashboards ([8f72358](https://github.com/soc-analyst/soc-analyst/commit/8f72358))


### Documentation

* **us-01:** markeer navigation menu story als klaar ([a55af4c](https://github.com/soc-analyst/soc-analyst/commit/a55af4c))
* **us-02:** markeer time range pickers story als klaar ([d381a27](https://github.com/soc-analyst/soc-analyst/commit/d381a27))
* **us-03:** markeer saved searches story als klaar ([6ff269c](https://github.com/soc-analyst/soc-analyst/commit/6ff269c))
* **us-05:** markeer KPI panels story als klaar ([8c92187](https://github.com/soc-analyst/soc-analyst/commit/8c92187))
* **us-10:** markeer makefile story als klaar ([feca426](https://github.com/soc-analyst/soc-analyst/commit/feca426))
* **us-11:** LOOKUPS.md met upload instructies ([6a6e4b1](https://github.com/soc-analyst/soc-analyst/commit/6a6e4b1))
* **us-12:** MIT License toegevoegd ([27fde38](https://github.com/soc-analyst/soc-analyst/commit/27fde38))
* **readme:** update README met Docker quick start ([ea5a4f8](https://github.com/soc-analyst/soc-analyst/commit/ea5a4f8))

## 1.0.0 (2025-09-15)


### Features

* Initiële projectstructuur
* Basis app configuratie (app.conf)
* 4 macros: soc_analyst, soc_endpoint, soc_auth, soc_network
* 5 basis dashboards: Overview, Security Alerts, Authentication, Endpoint, Network
* Sample saved search
