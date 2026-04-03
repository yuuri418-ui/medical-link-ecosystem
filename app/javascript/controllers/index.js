
import { Application } from "stimulus"
import BodySchemaController from "./body_schema_controller"
import HeatmapController from "./heatmap_controller"

// 2. Stimulusアプリケーションを起動する
const application = Application.start()

// 3. グローバルに公開する（デバッグ用）
window.application = application

// 4. コントローラーを登録する（最後に実行する）
application.register("body-schema", BodySchemaController)
application.register("heatmap", HeatmapController)

export { application }