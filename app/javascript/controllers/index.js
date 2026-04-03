
import { Application } from "stimulus"

// 1. まず Stimulus アプリケーションの土台（application）を定義する
const application = Application.start()

// 2. 作成した土台をグローバル（window）に公開する（これでエラーが消えます）
window.Application = application

// 3. 全身シェーマのコントローラーをインポートして登録する
import BodySchemaController from "./body_schema_controller"
application.register("body-schema", BodySchemaController)

export { application }