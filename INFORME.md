# Informe Técnico y Profesional: Addon EZOAlerts

**Fecha de análisis:** Julio 2024
**Versión analizada:** 0.1.24 (Public Beta)
**Juego:** The Elder Scrolls Online (ESO)

---

## 1. Resumen Ejecutivo
**EZOAlerts** es un addon modular e independiente diseñado para The Elder Scrolls Online. Su propósito principal es proveer un sistema de alertas visuales en pantalla (HUD) y notificaciones controladas en el chat de grupo. Forma parte de la familia de addons EZO, destacándose por su enfoque no invasivo, centrado en la consciencia situacional del grupo y roles de los jugadores, sin reemplazar la interfaz nativa de combate u otras mecánicas fundamentales del juego.

## 2. Arquitectura y Diseño Modular
El código fuente revela una estructura altamente organizada y modular, lo cual facilita su mantenimiento y escalabilidad.

- **Punto de entrada (`EZOAlerts.lua`):** Gestiona el inicio del addon, registro de eventos, carga de configuraciones guardadas y la comunicación con servicios externos.
- **Módulos Independientes (`/modules/`):**
  - `renderer.lua`: Renderizado de la ventana HUD de alertas con estilos (info, warning, error).
  - `group_chat.lua` y `channels.lua`: Manejo y control de la salida en los canales de chat.
  - `alert_registry.lua` y `group_events.lua`: Registro y despacho de eventos a nivel local y grupo.
  - `producers.lua`: Centraliza los diferentes "productores" o generadores de alertas.
  - `i18n.lua`: Sistema de internacionalización (inglés y español).
- **Integración con Ecosistema EZO (`EZOCore`):** Si bien puede operar solo con `LibAddonMenu-2.0`, se integra nativamente con `EZOCore` para compartir configuración (pestaña `Settings > EZO`), sincronización de idioma, distribución en pantalla compartida y registros de depuración unificados.

## 3. Características Principales (Productores de Alertas)
El sistema funciona bajo el modelo de "productores", componentes aislados encargados de detectar eventos específicos y emitir alertas:

1. **Cofres (Chest Alerts):** Detecta aperturas a través de eventos de ganzúa o botín, informando la calidad del cofre.
2. **Sacos Pesados (Heavy Sack Alerts):** Notifica cuando un miembro interactúa con un saco pesado.
3. **Comprobación de Rol (Role Check):** Un sistema inteligente que compara el rol asignado en grupo (Tanque, Sanador, Daño) con las armas equipadas y habilidades básicas configuradas. Emite alertas (warnings/alarms) si detecta incongruencias, como un sanador sin bastón de restauración.
4. **Zonas del Líder de Grupo:** Avisa cuando el líder del grupo cambia de zona o instancia, evitando desincronización en el equipo.
5. **Gremios Compartidos (Shared-guild Alerts):** Escanea a los miembros del grupo para identificar gremios en común con el usuario, útil para eventos sociales y de clan.

## 4. Políticas de Seguridad e Integridad (Safety Boundaries)
Una de las fortalezas de EZOAlerts es su compromiso estricto con los términos de servicio (TOS) y la experiencia del jugador original:
- **Ausencia de automatización:** No automatiza combate, viajes ni cambios de rol.
- **No es intrusivo:** No escanea sets de equipamiento, no intercepta inputs globales del teclado ni reemplaza elementos core del UI (barras de acción, menú de grupo).
- **Control de spam:** Limita las notificaciones al chat de grupo e incluye tiempos de reutilización (cooldowns) para evitar la saturación.
- **Validación estricta:** Los avisos de grupo compartidos requieren que tanto emisor como receptor cuenten con las dependencias necesarias (`EZOCore`, `LibGroupBroadcast`), evitando alteraciones en clientes de terceros.

## 5. Conclusión y Evaluación Técnica
EZOAlerts se presenta como un proyecto con estándares de calidad de software elevados para el desarrollo de addons en Lua. Su arquitectura orientada a eventos, el aislamiento entre la lógica de generación de datos (producers) y la presentación (renderer), y su capacidad tanto *standalone* como integrada, lo hacen una herramienta robusta y escalable. Se percibe un fuerte enfoque en el rendimiento del cliente y en proveer un código limpio y auditable.
