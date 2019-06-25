<template>
  <div :class="page.class">
    <rpl-page-layout
      v-if="page && pageType"
      :sidebar="sidebar"
      :backgroundColor="page.field_landing_page_bg_colour"
      :heroBackgroundImage="page.appHeroBgImage"
      :backgroundGraphic="heroBgGraphic"
      :class="{ 'app-home': page.appIsHome }"
      class="app-main"
    >
      <template slot="breadcrumbs">
        <rpl-breadcrumbs v-if="!page.appIsHome" :crumbs="page.breadcrumbs" />
      </template>

      <template slot="aboveContent">
        <component
          :is="heroBanner.component"
          v-if="heroBanner"
          v-bind="heroBanner.data"
          class="rpl-site-constrain--on-all"
        />
      </template>

      <template slot="aboveContentTwo">
        <template v-if="headerComponents">
          <template v-for="headerComponent in headerComponents">
            <component
              :is="headerComponent.component"
              v-bind="headerComponent.data"
              :class="headerComponent.class"
              :key="headerComponent.id"
              v-on="headerComponent.name === 'rpl-search-form' ? { search: ($event) => { return searchFunc($event, headerComponent.data.type)} } : {}"
              v-if="headerComponent && headerComponent.component"
            ></component>
          </template>
        </template>
        <template v-if="campaignPrimary && campaignPrimary.component">
          <component
            :is="campaignPrimary.component"
            v-bind="campaignPrimary.data"
          ></component>
        </template>
      </template>

      <component :is="pageType" :page="page" :anchor-links="anchorLinks" :sidebar="sidebar"></component>
      <rpl-updated-date v-bind="updatedDate.data"></rpl-updated-date>

      <template slot="sidebar">
        <app-sidebar :sidebarComponents="sidebarComponents"></app-sidebar>
      </template>

      <template slot="belowContent">
        <component class="rpl-site-constrain--on-all" v-if="campaignSecondary" :is="campaignSecondary.component" v-bind="campaignSecondary.data"></component>
        <app-content-rating v-if="page.field_show_content_rating" class="rpl-site-constrain--on-all"/>
      </template>

    </rpl-page-layout>

    <rpl-page-layout v-else class="app-main">
      <app-error :type="errorType || '404'" />
    </rpl-page-layout>
  </div>
</template>

<script>
// Tide
import RplAccordion from '@dpc-sdp/ripple-accordion'

// App.
import AppError from '../components/AppError'
import AppContentRating from '../components/AppContentRating'
import AppSidebar from '../components/AppSidebar'
import RplUpdatedDate from '@dpc-sdp/ripple-updated-date'

// Layout.
import { RplRow, RplCol } from '@dpc-sdp/ripple-grid'
import { RplPageLayout } from '@dpc-sdp/ripple-layout'
import RplBreadcrumbs from '@dpc-sdp/ripple-breadcrumbs'

// Banner.
import { RplHeroBanner, RplIntroBanner } from '@dpc-sdp/ripple-hero-banner'

import middleware from '@dpc-sdp/ripple-nuxt-tide/lib/core/middleware'
import { loadComponent, dComponentsLoader, dComponentLoader } from '@dpc-sdp/ripple-nuxt-tide/lib/core/componentLoader'

import { anchorUtils } from '@dpc-sdp/ripple-nuxt-tide/lib/core/anchorlinks.js'
import kebabCase from 'lodash.kebabcase'

export default {
  components: {
    AppError,
    AppContentRating,
    AppSidebar,
    RplAccordion,
    RplHeroBanner,
    RplIntroBanner,
    RplUpdatedDate,
    RplBreadcrumbs,
    RplPageLayout,
    RplRow,
    RplCol
  },
  head () {
    return this.page.head
  },
  data () {
    return {
      page: null,
      sidebar: false,
      campaignPrimary: null,
      campaignSecondary: null,
      heroBanner: null,
      sidebarComponents: null

    }
  },
  created () {
    if (this.page.appCampaignPrimary) {
      this.campaignPrimary = dComponentLoader(this.page.appCampaignPrimary, this.page.sidebar)
    }
    if (this.page.appCampaignSecondary) {
      this.campaignSecondary = dComponentLoader(this.page.appCampaignSecondary, this.page.sidebar)
    }
    if (this.page.appHeroBanner) {
      this.heroBanner = dComponentLoader(this.page.appHeroBanner)
    }
    if (this.page.sidebarComponents && this.page.sidebarComponents.length > 0) {
      this.sidebarComponents = dComponentsLoader(this.page.sidebarComponents, this.page.sidebar)
    }
  },
  methods: {
    searchFunc (searchInput, contentType) {
      let path = ''
      let filters = ''
      switch (contentType) {
        case 'event':
          path = '/whatson'
          break
        case 'news':
          path = '/search'
          filters = {'type': 'news'}
          break
        default:
          path = '/search'
          break
      }
      this.$tideSearch.searchPageRedirect(path, searchInput, filters)
    }
  },
  computed: {
    anchorLinks () {
      if (this.page.field_show_table_of_content && this.page.appDComponents) {
        const anchors = []
        this.page.appDComponents.forEach(component => {
          if (component && component.name && component.data) {
            switch (component.name) {
              case 'rpl-markup':
                if (component.data.html) {
                  anchors.push(...anchorUtils.getAnchorLinks(component.data.html))
                }
                break
              case 'rpl-accordion':
                if (component.data.title) {
                  anchors.push({text: component.data.title, url: `#${kebabCase(component.data.title)}`})
                }
                break
            }
          }
        })
        return anchors
      }
      return []
    },
    heroBgGraphic () {
      if (this.page.field_graphical_image && this.page.field_graphical_image.field_media_image) {
        return this.page.field_graphical_image.field_media_image.url
      } else {
        return '/img/header-pattern-shape.png'
      }
    },
    updatedDate () {
      return {
        component: () => loadComponent('rpl-updated-date'),
        data: {
          date: this.page.changed.toString() || this.page.created.toString()
        }
      }
    },
    headerComponents () {
      if (this.page.appHeaderComponents && this.page.appHeaderComponents.length > 0) {
        return dComponentsLoader(this.page.appHeaderComponents, this.page.sidebar)
      }
      return []
    },
    pageType () {
      if (this.page.type) {
        return this.$tide.getPageTypeTemplate(this.page.type)
      } else {
        return false
      }
    }
  },
  async asyncData (context) {
    // Do not modify context.
    // Middleware should store any generated page data in results object.
    const results = {}
    await middleware(context, results)

    try {
      const customMiddlewares = context.app.$tide.getCustomMiddleware()
      for (const mw in customMiddlewares) {
        await customMiddlewares[mw](context, results)
      }
    } catch (error) {
      if (process.server) {
        console.log(error)
      }
    }

    return {
      errorType: results.tideErrorType,
      page: results.tidePage,
      sidebar: results.tideLayout ? results.tideLayout.sidebar : false
    }
  }
}
</script>