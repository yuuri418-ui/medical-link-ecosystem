import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(e) {
    e.preventDefault()
    // テンプレートから新しい入力欄を作成し、インデックスをユニークな数値に置換
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.target.closest('.nested-fields')
    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      // 既存データの場合は _destroy を 1 にして非表示にする
      wrapper.querySelector("input[name*='_destroy']").value = "1"
      wrapper.style.display = 'none'
    }
  }
}