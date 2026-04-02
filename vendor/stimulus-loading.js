// vendor/javascript/stimulus-loading.js
// Stimulus auto-loading helper for use with import map.

export function registerControllersForLazyLoad(parent, application) {
  const elements = parent.querySelectorAll('[data-controller]')
  elements.forEach((element) => {
    const controllerNames = element.getAttribute('data-controller').split(/\s+/)
    controllerNames.forEach((name) => {
      if (!application.router.modulesByIdentifier.has(name)) {
        import(name).then((module) => {
          application.register(name, module.default)
        })
      }
    })
  })
}

export function lazyLoadControllersFrom(under, application, element = document) {
  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type === 'childList') {
        registerControllersForLazyLoad(mutation.target, application)
      } else if (mutation.type === 'attributes' && mutation.attributeName === 'data-controller') {
        registerControllersForLazyLoad(mutation.target, application)
      }
    }
  })

  registerControllersForLazyLoad(element, application)
  observer.observe(element, { childList: true, subtree: true, attributes: true, attributeFilter: ['data-controller'] })
}