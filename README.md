# MangaReader

App iOS en SwiftUI para **buscar, explorar y leer manga** de MangaDex.

- Lista de mangas populares con portada, título y estado.
- Búsqueda por título (botón de lupa).
- Detalle con portada grande, estado y descripción.
- **Lector integrado**: capítulos disponibles y lectura página a página dentro de la app.

Navegación de dos niveles: lista → detalle (más lector: detalle → capítulos → páginas).

## API

Todos los endpoints son de la API pública de MangaDex (https://api.mangadex.org/docs/):

| Uso | Endpoint (GET) |
| --- | --- |
| Mangas populares | `https://api.mangadex.org/manga?order[followedCount]=desc&includes[]=cover_art&limit=20&contentRating[]=safe` |
| Búsqueda | `https://api.mangadex.org/manga?title=<texto>&includes[]=cover_art&limit=20&contentRating[]=safe` |
| Capítulos de un manga | `https://api.mangadex.org/chapter?manga=<id>&translatedLanguage[]=es&translatedLanguage[]=en&order[chapter]=asc` |
| Páginas de un capítulo | `https://api.mangadex.org/at-home/server/<chapterId>` |

Nota: los capítulos con licencia oficial (externalUrl, p. ej. MangaPlus) no se pueden leer en MangaDex; la app los filtra y avisa cuando un manga no tiene capítulos disponibles.

## Requisitos y ejecución

- Xcode 26 (o superior) con SDK de iOS 17.6+
- iOS 17.6+ (simulador o dispositivo)

Pasos:

1. Clonar el repositorio.
2. Abrir `MangaReader.xcodeproj` en Xcode.
3. Elegir un simulador de iPhone y presionar **Run (⌘R)**.

## Arquitectura (MVVM)

- **Model**: `Manga`, `Chapter` (+ sus DTOs para decodificar el JSON).
- **ViewModel**: `MangaListViewModel`, `SearchViewModel`, `ReaderViewModel` — publican estado con `@Observable`.
- **View**: `MangaListView`, `SearchView`, `MangaDetailView`, `ReaderView`, `ChapterReaderView` y componentes pequeños (`MangaRowView`, `ChapterRowView`, `ErrorView`, `MangaPageView`).
- **Services**: `MangaService` — única clase que habla con la red (una función `get` genérica evita duplicar lógica); `NetworkError` — errores con mensajes legibles.

## Manejo de errores y estados

- Sin internet → "Sin conexión a internet. Inténtalo de nuevo."
- Error del servidor → se muestra el código HTTP.
- Estado de carga → `ProgressView` en lista, búsqueda, capítulos y páginas.
- Pantallas de error con botón **Reintentar**; la app nunca truena por errores de red.

## Accesibilidad

- Las filas se combinan en un solo elemento de VoiceOver.
- La portada del detalle y las páginas del lector tienen `accessibilityLabel`.
- El botón de búsqueda tiene etiqueta de accesibilidad.
