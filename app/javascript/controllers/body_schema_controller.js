import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["part", "input"]

  connect() {
    // 保存済みのデータがあれば読み込む
    this.selectedParts = JSON.parse(this.inputTarget.value || "[]")
    this.refresh()
  }

  toggle(event) {
    const id = event.currentTarget.id
    if (this.selectedParts.includes(id)) {
      this.selectedParts = this.selectedParts.filter(p => p !== id)
    } else {
      this.selectedParts.push(id)
    }
    // 隠しフィールドにJSON文字列として保存
    this.inputTarget.value = JSON.stringify(this.selectedParts)
    this.refresh()
  }

  refresh() {
    // 全てのパーツを一旦リセットしてから、選択中のものだけ赤くする
    this.partTargets.forEach(part => {
      if (this.selectedParts.includes(part.id)) {
        part.setAttribute("fill", "#ef4444") // 警告の赤
      } else {
        part.setAttribute("fill", "#e5e7eb") // 通常のグレー
      }
    })
  }
}