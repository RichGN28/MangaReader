# MangaReader

App iOS en SwiftUI que muestra los mangas más populares de **MangaDex** y su detalle (portada, estado y descripción), con navegación de dos niveles: lista → detalle.

## API

- Endpoint usado (GET): `https://api.mangadex.org/manga?limit=20&includes[]=cover_art&order[followedCount]=desc&contentRating[]=safe`
- Documentación oficial: https://api.mangadex.org/docs/

## Requisitos y ejecución

- Xcode 26 (o superior) con SDK de iOS 17.6+
- iOS 17.6+ (simulador o dispositivo)

Pasos:

1. Clonar el repositorio.
2. Abrir `MangaReader.xcodeproj` en Xcode.
3. Elegir un simulador de iPhone y presionar **Run (⌘R)**.

## Arquitectura (MVVM)

- **Model**: `Manga` + `MangaDTO` (decodificación del JSON de la API).
- **ViewModel**: `MangaListViewModel` — publica el estado (`loading`, `loaded`, `error`) con `@Observable`.
- **View**: `MangaListView` (lista), `MangaDetailView` (detalle), `MangaRowView` y `ErrorView` (vistas pequeñas de una sola responsabilidad).
- **Services**: `MangaService` — única clase que habla con la red; `NetworkError` — errores con mensajes legibles.

## Manejo de errores y estados

- Sin internet → mensaje amigable: "Sin conexión a internet. Inténtalo de nuevo."
- Error del servidor → se muestra el código HTTP.
- Estado de carga → `ProgressView`.
- Pantalla de error con botón **Reintentar**; la app nunca truena por errores de red.

## Accesibilidad

- Las filas se combinan en un solo elemento de VoiceOver.
- La portada del detalle tiene `accessibilityLabel` con el título del manga.
