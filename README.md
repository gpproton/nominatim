# Nominatim Nigeria & Ghana easy setup

A docker compose easy nominatim Nigeria & Ghana geocoder setup.

## Requirements

- docker
- docker compose

## Run setup script

```bash
git clone https://github.com/gpproton/nominatim-africa-setup.git
```

```yml
version: "3"
services:
  geocoder:
    image: gpproton/nominatim-nigeria-ghana
    volumes:
      - ./backups/:/srv/nominatim/backups/:rw
    environment:
      # RESTORE | CREATE
      - "NOMINATIM_MODE=CREATE"
      - "NOMINATIM_PBF_URL=https://storage.11s.cloud/osm/nigeria-ghana-2021-06.osm.pbf"
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        max_attempts: 3
      update_config:
        parallelism: 1
        delay: 30s
      resources:
        limits:
          cpus: "1.5"
          memory: 2G
        reservations:
          cpus: "0.1"
          memory: 100M
    ulimits:
      rtprio: 95
      memlock: -1
      nproc: 1024000
      nofile:
        soft: 1024000
        hard: 1024000
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 1m
      timeout: 3m
      retries: 5
    ports:
      - "18095:8080"
```

## Build and run container instance

```bash
docker-compose --compatibility build --no-cache && docker-compose --compatibility up -d
```

## Monitor log for instance

```bash
docker-compose --compatibility logs -f
```

## Test reverse geocode

```bash
curl 'http://swarm.srv.bhn.ng:18089/reverse.php?format=json&lat=7.6878561826248&lon=6.3472389957393&zoom=16'
```

`Expected output.`

```json
{
  "place_id": 279698,
  "licence": "Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright",
  "osm_type": "way",
  "osm_id": 194738931,
  "lat": "7.68726177198402",
  "lon": "6.3491445347232975",
  "display_name": "Okehi, Kogi, Nigeria",
  "address": {
    "county": "Okehi",
    "state": "Kogi",
    "country": "Nigeria",
    "country_code": "ng"
  },
  "boundingbox": ["7.6338249", "7.6965915", "6.3301211", "6.3506716"]
}
```
