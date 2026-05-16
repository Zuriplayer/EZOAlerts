# EZOAlerts Architecture

`EZOAlerts` separa productores, registro, persistencia y renderizado.

## Flujo

1. Un modulo productor llama a `EZOAlerts.ShowAlert(text, kind, options)`.
2. `alert_registry.lua` mantiene una API publica pequena para avisos directos o registrados.
3. `renderer.lua` crea y actualiza el unico control visual.
4. `menu.lua` expone configuracion basica en LibAddonMenu.

## Contratos

- Los productores no deben conocer controles UI.
- El renderer no debe decidir reglas de negocio.
- Las SavedVariables deben vivir en `saved_vars.lua`.
- La localizacion debe vivir en `lang/en.lua` y `lang/es.lua`.

## Kinds

- `info`
- `warning`
- `error`

Estos valores deben permanecer simples porque luego pueden mapearse a estilos de `EZOTools`.
