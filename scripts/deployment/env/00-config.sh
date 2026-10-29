#!/usr/bin/env bash
# scripts/deployment/env/00-config.sh
# Constantes del proyecto oracle-database-lab. Uso: source scripts/deployment/env/00-config.sh

export CONT_NAME="oralab-26ai"
export VOL_NAME="oralab-26ai-data"
export IMG="container-registry.oracle.com/database/free:latest"
export PORT_DB=1521
export PORT_ORDS=8181   # Lab 4: OBSOLETA. ORDS corre en Linux y escucha en ORDS_PORT (8080)
export SERVICE_CDB="FREE"
export SERVICE_PDB="FREEPDB1"
export BACKUP_DIR="$(pwd)/backups"
export EVID="docs/bitacora/evidencia"

ts() { date -u +%Y%m%dT%H%M%SZ; }
# Lab 4: operacion del entorno (backup/restauracion y evidencia)
export HELPER_IMG="ubuntu:24.04"
export DATA_ROOT="/opt/oracle/oradata"
export EVID_LAB4="docs/bitacora/lab4/evidencia"
export EVID_LAB5="docs/bitacora/lab5/evidencia"
