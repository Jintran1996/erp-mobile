# Kiến trúc module — chuẩn MSRPSW

> Tài liệu này lấy module **`budget_plan`** làm chuẩn tham chiếu (reference
> implementation) cho pattern **MSRPSW** đang được áp dụng dần cho toàn bộ
> app (xem lịch sử refactor "MSRPSW architecture" ở module `expense`).
> Khi tạo module mới hoặc refactor module cũ, hãy đối chiếu với các file
> trong `lib/features/finance/budget_plan/` làm mẫu.

**MSRPSW** = **M**odel → **S**ervice → **R**epository → **P**rovider →
**S**creen → **W**idget. Đây là thứ tự dữ liệu chảy từ API đến UI, và cũng
là thứ tự nên đọc/viết code khi làm 1 module mới.

```
DTO (data thô từ API)
   │  Service.fromJson
   ▼
Model (data đã xử lý cho UI, có computed properties)
   │  Repository.map DTO → Model
   ▼
Provider (ChangeNotifier — state: loading/error/items/filter)
   │  context.watch / context.read
   ▼
Screen (StatelessWidget/StatefulWidget lắp layout + gọi Provider)
   │
   ▼
Widget (component tái sử dụng: Card, Chip, Field...)
```

## 1. Cấu trúc thư mục chuẩn

```
lib/features/<domain>/<module>/
├── data/
│   ├── dtos/            # *_dto.dart      — parse JSON, KHÔNG có business logic
│   ├── models/           # *_model.dart    — data cho UI + computed properties
│   ├── services/          # *_service.dart  — gọi ApiClient, trả về DTO
│   └── repositories/      # *_repository.dart — DTO → Model, tầng DUY NHẤT biết cả 2
├── providers/            # *_provider.dart — ChangeNotifier, state cho Screen
└── presentation/
    ├── screens/           # *_screen.dart   — layout, đọc Provider
    └── widgets/           # *_card.dart, *_field.dart... — component tái dùng
```

Ví dụ thực tế trong `budget_plan/`:

```
data/dtos/budget_plan_dto.dart
data/models/budget_plan_model.dart
data/services/budget_plan_service.dart
data/repositories/budget_plan_repository.dart
providers/budget_plan_provider.dart
providers/budget_plan_detail_provider.dart
providers/following_list_provider_base.dart   # base class dùng chung
presentation/screens/budget_plan_screen.dart
presentation/screens/budget_plan_detail_screen.dart
presentation/widgets/budget_plan_card.dart
presentation/widgets/app_tab_bar.dart
```

## 2. Từng tầng — trách nhiệm & quy tắc

### 2.1. DTO (`data/dtos/*_dto.dart`)

- Map **1-1** với JSON response, không có logic nghiệp vụ, không có
  computed property.
- Mọi field nullable trừ khi API luôn trả về.
- Factory `fromJson` luôn có fallback an toàn (`?? ''`, `?? 0`, `?? false`)
  — **không bao giờ để field bắt buộc bị null / throw khi parse**.
- DTO con lồng nhau parse qua factory riêng (`BudgetDepartmentDto.fromJson`),
  không parse Map thủ công ngay trong DTO cha.
- Model chi tiết (detail) thì **extends** DTO danh sách (`BudgetPlanDetailDto
  extends BudgetPlanDto`) để tái dùng field chung, chỉ thêm field mới.

```dart
factory BudgetPlanDto.fromJson(Map<String, dynamic> j) => BudgetPlanDto(
      id: j['id']?.toString() ?? '',
      totalAmount: (j['totalAmount'] as num?) ?? 0,
      department: j['department'] != null
          ? BudgetDepartmentDto.fromJson(j['department'] as Map<String, dynamic>)
          : null,
    );
```

### 2.2. Model (`data/models/*_model.dart`)

- Dữ liệu **đã xử lý cho UI**: gộp field, tính toán sẵn (`remainingAmount`,
  `periodLabel`, `departmentDisplay`, `usagePercent`...) để Screen/Widget
  không tính toán lặp lại trong `build()`.
- Static `fromDto(Dto)` — **không** có `fromJson` (Model không biết JSON).
- Config hiển thị (màu trạng thái, label) khai báo dạng `Map<int, XxxCfg>`
  cạnh Model, không hard-code màu trong Widget.
- Model chi tiết cũng `extends` Model danh sách, tương tự DTO.

```dart
num get remainingAmount => totalAmount - usedAmount;
String get periodLabel => 'T$periodMonth - $periodYear';

static BudgetPlanModel fromDto(BudgetPlanDto dto) => BudgetPlanModel(
      id: dto.id,
      departmentName: dto.department?.name,
      periodYear: dto.budgetPeriod?.year ?? 0,
      ...
    );
```

### 2.3. Service (`data/services/*_service.dart`)

- **Chỉ** gọi `ApiClient`, trả **DTO thô**. Không biết gì về Model hay UI.
- Singleton qua private constructor: `Service._()` + `static final instance`.
- Mỗi method ứng với 1 endpoint, đặt tên theo action (`getFollowing`,
  `getDetail`, `review`, `approve`, `returnPlan`, `cancelPlan`).
- Luôn kiểm tra `res['isSuccess']` cho POST/action, throw `Exception` với
  message từ API khi thất bại; GET danh sách thì đọc `res['data']` an toàn
  (`raw is List ? raw : []`).

```dart
class BudgetPlanService {
  BudgetPlanService._();
  static final BudgetPlanService instance = BudgetPlanService._();
  final _api = ApiClient.instance;

  Future<List<BudgetPlanDto>> getFollowing({...}) async { ... }
}
```

### 2.4. Repository (`data/repositories/*_repository.dart`)

- Tầng **duy nhất** import cả DTO lẫn Model — nơi convert `DTO → Model`.
- Singleton giống Service.
- Method mirror 1-1 theo Service, không thêm logic khác ngoài việc gọi
  Service rồi `.map(Model.fromDto)`.
- Exception riêng của domain (nếu cần) khai báo cuối file, vd
  `BudgetPlanException`.

```dart
Future<List<BudgetPlanModel>> getFollowing({...}) async {
  final dtos = await _service.getFollowing(...);
  return dtos.map(BudgetPlanModel.fromDto).toList();
}
```

### 2.5. Provider (`providers/*_provider.dart`)

- `ChangeNotifier`, sở hữu **state UI**: `loading`, `error`, `items`, các
  field filter riêng của module (`fromDate/toDate`, `year/month`...).
- **Danh sách "following" (list + filter) nên kế thừa
  `FollowingListProviderBase<T>`** (`providers/following_list_provider_base.dart`)
  thay vì tự viết lại loading/error/race-condition:
  - Base lo sẵn: `loading`, `error`, `rawItems`, `items` (đã lọc theo
    `search`), chống race-condition khi `load()` bị gọi liên tiếp
    (`_requestId`).
  - Subclass chỉ cần override `fetchItems()` (gọi Repository theo filter
    hiện tại) và `matchesSearch(item, query)`.
  - Mỗi setter filter (`setFromDate`, `setYear`...) tự gọi `load()`; nếu
    đổi nhiều field cùng lúc, thêm 1 hàm gộp (`setDateRange`,
    `setYearMonth`) để chỉ gọi `load()` **một lần**.
- Provider cho màn **detail** (1 item, có action review/approve/reject) thì
  **không** dùng base list — tự viết `ChangeNotifier` riêng với `detail`,
  `loading`, `error`, `acting` (cờ riêng cho lúc đang submit action) —
  xem `budget_plan_detail_provider.dart`.
- Action (`review`, `approve`, `reject`) trả `Future<bool>` (thành công/thất
  bại) để Screen quyết định hiển thị SnackBar/điều hướng, **không** để
  Provider tự làm UI.

```dart
class BudgetPlanProvider extends FollowingListProviderBase<BudgetPlanModel> {
  final _repo = BudgetPlanRepository.instance;
  DateTime _fromDate = ...;
  DateTime get fromDate => _fromDate;

  void setFromDate(DateTime d) { _fromDate = d; load(); }

  @override
  Future<List<BudgetPlanModel>> fetchItems() =>
      _repo.getFollowing(fromDate: _fromDate, toDate: _toDate, status: _statusFilter);

  @override
  bool matchesSearch(BudgetPlanModel item, String query) =>
      item.departmentDisplay.toLowerCase().contains(query);
}
```

### 2.6. Screen (`presentation/screens/*_screen.dart`)

- Khai báo Provider bằng `MultiProvider` + `ChangeNotifierProvider(create:
  (_) => XxxProvider()..load())` ngay tại Screen — Provider **scope theo
  màn hình**, không đặt ở app root trừ khi thực sự cần chia sẻ toàn app.
- Bọc `Builder` bên dưới `MultiProvider` để có `BuildContext` mới, nếu
  không thao tác `context.read<Provider>()` ngay trong Scaffold (vd nút
  refresh trên header) sẽ không tìm thấy Provider.
- Đọc state bằng `context.watch<Provider>()` ở đầu `build()`, gọi action
  qua `context.read<Provider>()` trong callback (`onPressed`, `onTap`).
- List UI luôn xử lý đủ **4 trạng thái** theo đúng thứ tự check:
  `loading → error → empty → data`, mỗi trạng thái là 1 hàm private riêng
  (`_buildList`, tách nhỏ theo state) — xem `_BudgetPlanView._buildList`.
  Nút "Thử lại" khi lỗi luôn gọi lại `p.load`.
- List thật sự bọc trong `RefreshIndicator(onRefresh: p.load, ...)`.
- Filter bar và summary (tổng số lượng + tổng tiền) tách thành hàm private
  riêng (`_buildFilterBar`, `_buildSummary`), không nhúng trực tiếp trong
  `build()`.
- Nếu màn hình có nhiều tab cùng loại dữ liệu (list + filter khác nhau),
  mỗi tab là 1 `StatelessWidget` riêng (`_BudgetPlanView`,
  `_BudgetPlanAdjustmentView`) watch đúng 1 Provider của nó — không gộp
  logic 2 tab vào chung 1 widget.

### 2.7. Widget (`presentation/widgets/*.dart`)

- Nhận **Model** (không nhận DTO) + callback (`onTap`) qua constructor,
  không tự gọi Provider/Repository bên trong Widget hiển thị (Card, Chip).
- Widget con dùng riêng trong 1 file (avatar, chip nhỏ...) khai báo
  `private class` (`_InfoChip`, `_UserAvatar`) ngay cuối file chứa Widget
  chính, không tách file riêng nếu chỉ dùng nội bộ.
- Định dạng số tiền/ngày tháng dùng chung `expense_formatters.dart`
  (`formatMoney`, `formatDate`) — **không** tự viết `NumberFormat` lặp lại
  ở từng Widget.
- Màu sắc trạng thái lấy từ `Model.statusCfg` (đã định nghĩa ở tầng Model),
  Widget chỉ `Color(cfg.bg)` / `Color(cfg.text)`, không hard-code theo
  `status` số nguyên trong Widget.

## 3. Quy ước đặt tên & import

- File: `snake_case`, hậu tố theo tầng: `_dto.dart`, `_model.dart`,
  `_service.dart`, `_repository.dart`, `_provider.dart`, `_screen.dart`.
  **Không để dấu cách trong tên file** (vd tránh kiểu
  `budget_plan_screen copy.dart`).
- Class: `PascalCase` cùng tiền tố với module (`BudgetPlan...`), hậu tố
  đúng tầng (`...Dto`, `...Model`, `...Service`, `...Repository`,
  `...Provider`, `...Screen`).
- Import nội bộ module dùng đường dẫn **tương đối** (`../../data/models/...`),
  chỉ dùng đường dẫn `package:` khi import chéo module khác
  (`../../../../../features/expense/_shared/expense_formatters.dart`).
- Mỗi file bắt đầu bằng comment 2 dòng: đường dẫn file + 1 dòng mô tả
  ngắn vai trò tầng đó (xem header mọi file trong `budget_plan/`).

## 4. Checklist khi tạo module mới theo chuẩn này

1. `data/dtos/xxx_dto.dart` — field khớp JSON, fallback an toàn khi parse.
2. `data/models/xxx_model.dart` — `fromDto`, computed properties, status
   config nếu có trạng thái.
3. `data/services/xxx_service.dart` — singleton, 1 method / endpoint, check
   `isSuccess` cho action.
4. `data/repositories/xxx_repository.dart` — singleton, map DTO → Model.
5. `providers/xxx_provider.dart` — danh sách thì kế thừa
   `FollowingListProviderBase<T>`; chi tiết thì tự viết `ChangeNotifier`
   với `acting` riêng cho action.
6. `presentation/screens/xxx_screen.dart` — `MultiProvider` + `Builder`,
   tách `_buildFilterBar` / `_buildSummary` / `_buildList` (4 state).
7. `presentation/widgets/xxx_card.dart` — nhận Model + callback, dùng
   `expense_formatters.dart` cho format tiền/ngày.
8. Chạy `flutter analyze` trên module mới trước khi coi là xong.
