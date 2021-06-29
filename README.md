# Nominatim Nigeria & Ghana easy setup

A docker compose easy nominatim Nigeria & Ghana geocoder setup.

## Requirements

- docker
- docker compose

## Run setup script

```bash
git clone https://github.com/gpproton/nominatim-africa-setup.git
```

## Build and run container instance

```bash
docker-compose build --no-cache && docker-compose up -d
```

## Monitor log for instance

```bash
docker-compose logs -f
```

## Test reverse geocode

```bash
curl 'http://localhost:8055/reverse?lon=-0.143&lat=5.5535'
```

`Expected output.`

```xml
<reversegeocode timestamp="Wed, 26 May 21 01:47:47 +0000" attribution="Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright" querystring="lon=-0.143&lat=5.5535">
<result place_id="1947781" osm_type="node" osm_id="105940398" ref="South La Estates" lat="5.5545345" lon="-0.1656563" boundingbox="5.5345345,5.5745345,-0.1856563,-0.1456563" place_rank="19" address_rank="20">South La Estates, La, Accra, Greater Accra Region, 6237, Ghana</result>
<addressparts>
<suburb>South La Estates</suburb>
<town>La</town>
<city>Accra</city>
<state>Greater Accra Region</state>
<postcode>6237</postcode>
<country>Ghana</country>
<country_code>gh</country_code>
</addressparts>
</reversegeocode>
```
