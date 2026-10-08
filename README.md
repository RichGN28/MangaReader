# MangaReader

App iOS en SwiftUI para **explorar y buscar manga** de MangaDex.

- Lista de mangas populares con portada, título y estado.
- Búsqueda por título (botón de lupa).
- Detalle con portada grande, estado, descripción y enlace para leer en MangaDex.

Navegación de dos niveles: lista → detalle.

## API

Endpoints de la API pública de MangaDex (https://api.mangadex.org/docs/):

| Uso | Endpoint (GET) |
| --- | --- |
| Mangas populares | `https://api.mangadex.org/manga?order[followedCount]=desc&includes[]=cover_art&limit=20&contentRating[]=safe` |
| Búsqueda | `https://api.mangadex.org/manga?title=<texto>&includes[]=cover_art&limit=20&contentRating[]=safe` |

## Requisitos y ejecución

- Xcode 26 (o superior) con SDK de iOS 17.6+
- iOS 17.6+ (simulador o dispositivo)

Pasos:

1. Clonar el repositorio.
2. Abrir `MangaReader.xcodeproj` en Xcode.
3. Elegir un simulador de iPhone y presionar **Run (⌘R)**.

## Arquitectura (MVVM)

- **Model**: `Manga` + `MangaDTO` (decodificación del JSON de la API).
- **ViewModel**: `MangaListViewModel` y `SearchViewModel` — publican el estado (`loading`, `loaded`, `error`) con `@Observable`.
- **View**: `MangaListView`, `SearchView`, `MangaDetailView` y componentes pequeños (`MangaRowView`, `ErrorView`).
- **Services**: `MangaService` — única clase que habla con la red; `NetworkError` — errores con mensajes legibles.
