# Demo dbt project

## Voorbereiding

De demo is gegeven met Python versie 3.9, maar zou in principe met elke versie vanaf 3.9 moeten werken.
Installeer de laatste versie van Python voor jouw [platform](https://www.python.org/downloads/)

Verder heb je Git [nodig](https://git-scm.com/downloads)

Ten slotte wordt in deze demo DuckDB gebruikt. Het is handig om de Command line versie van DuckDB te [installeren](https://duckdb.org/docs/installation/?version=stable),
maar je zou ook prima met de Python library voor DuckDB kunnen werken (deze wordt automatisch geïnstalleerd bij de installatie van `dbt-duckdb`, zie verderop.)

Om het jezelf nog gemakkelijker te maken is het aan te raden om bijvoorbeeld [DBeaver](https://dbeaver.io) te installeren. Deze SQL editor heeft een connector voor DuckDB.

### Clone de repository
Clone deze repository naar een directory op je pc.

### Maak een Python virtuele omgeving aan
Het is altijd aan te raden om voor ieder Python project een virtuele omgeving aan te maken. Zo kun je per project verschillende versies van Python en libraries gebruiken
en voorkom je conflicten als libraries globaal geïnstalleerd worden. Er zijn veel manieren en 3rd party tools om virtuele omgevingen te maken, maar het eenvoudigst
is om gewoon het ingebouwde script `venv` te gebruiken.

Ga in de command line naar de geclonede dbt-project directory en voer het volgende commando uit (Windows):

```
py -m venv .venv
```

Dit commando creëert een directory genaamd `.venv`. Vervolgens moet je de virtuele omgeving activeren. Voer het volgende commando uit (Windows):

```
.venv\Scripts\activate
```

Belangrijk: De instructies vanaf hier gaan ervan uit dat je de virtuele omgeving geactiveerd hebt. Dus ook het runnen van dbt commando's.
Het deactiveren van een Python virtuele omgeving doe je met het commando `deactivate`. Heractiveren doe je simpelweg weer met `.venv\Scripts\activate`.

### Installeer dbt-core en dbt-duckdb
Voer het volgende commando uit vanuit je virtuele omgeving:

```
pip install dbt-core dbt-duckdb
```
Nu kan je testen of dbt werkt door het volgende command in te voeren:

```
dbt debug
```

### TPC-H dataset laden in DuckDB
Er vanuit gaande dat je de DuckDB command line versie hebt geïnstalleerd, en deze executable is toegevoegd aan je PATH environment variabele, voer
je de volgende commando's uit om een database genaamd `dev.duckdb` aan te maken en deze te vullen met de TPC-H dataset:
```
duckdb dev.duckdb
```

Vervolgens in de DuckDB shell:
```
INSTALL tpch;
LOAD tpch;

CALL dbgen(sf = 1);
```
Bovenstaand commando neemt enige tijd in beslag en vraagt wat geheugen van je pc. Je kan spelen met de scale factor om nog grotere datasets te genereren, maar dit vraagt wel meer geheugen.
Het is ook mogelijk om stapsgewijs data te genereren en zo minder geheugen te gebruiken. Meer informatie over de TPC-H extensie lees je [hier](https://duckdb.org/docs/extensions/tpch.html)

Mocht je willen werken met de DuckDB Python library (in plaats van de command line tool), dan open je simpelweg een Python shell vanuit je virtuele omgeving:
```
python
```
Vervolgens kan je verbinding maken met de `dev.duckdb` database (of aanmaken als deze nog niet bestaat) en SQL-statements draaien:
```
import duckdb

con = duckdb.connect("dev.duckdb")
con.sql("INSTALL tpch;")
etc...
```

## dbt gebruiken

### dbt run
Om de modellen te draaien voer je het volgende commando uit:

```
dbt run --vars 'run_date: 2024-10-30'
```

Met de `--vars` optie kan je variabelen meegeven aan het dbt run commando. Let er op dat deze zijn gedefinieerd in `dbt_project.yml`.

### dbt test
Unit tests voer je uit **nadat** dbt run gedraaid heeft, anders mislukken ze, want de materialisaties (tabellen en views) bestaan immers nog niet in je database:

```
dbt test
```

## Een nieuw dbt-project starten "from scratch"
Wil je met een schoon/nieuw dbt-project beginnen, dan kan je de volgende stappen volgen:

1. Maak een nieuwe directory aan voor je virtuele omgeving. Bijvoorbeeld `mkdir mijn-dbt-project` en `cd mijn-dbt-project`
2. Maak een nieuwe Python virtuele omgeving: `py -m venv .venv`
3. Activeer de nieuwe omgeving: `.venv\Scripts\activate`
4. Installeer dbt en de connector die je wil gebruiken, bijvoorbeeld voor Duckdb: `pip install dbt-core dbt-duckdb`
5. Initialiseer een nieuw dbt project: `dbt init` en volg de instructies op het scherm
6. dbt maakt een nieuw project aan in een nieuwe directory onder je projectdirectory. Dit is ietwat onhandig omdat je waarschijnlijk alles in een directory wil hebben (dbt + Git + Python venv), maar helaas werkt het zo.
7. Het nieuwe project is niet helemaal leeg, er staan enkele 'dummy' modellen in.
8. dbt installeert het bestand `profiles.yml` standaard in de directory `~/.dbt`. Dit omdat je hier mogelijk database-credentials (wachtwoorden etc.) in opslaat, en je deze natuurlijk niet in je Git repo wil hebben staan.
