import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/createmenu/index.html'),
    data: () => ({
        selectBusiness: false,
        businessAccessPage: [],
        jobs: [],
        selectedJob: false,
        coords: null,
        businessBossRank: 4,
        logo: null,
        theme : 'blue',
    }),
    methods: {
        SetTheme(value){
            this.theme = value
        },
        toggleBusinessAccessPage(value) {
            let find = this.businessAccessPage.find((val) => value == val)
            if (find) {
                this.businessAccessPage = this.businessAccessPage.filter((val) => value != val)

            } else {
                this.businessAccessPage.push(value)
            }
        },
        createMenu() {
            postNUI('createMenu', {
                pageaccess: this.businessAccessPage,
                company: this.selectedJob.name,
                joblabel : this.selectedJob.label,
                logo: this.logo,
                bossrank: this.businessBossRank,
                theme : this.theme,
                location: JSON.parse(this.coords),
            })
        },
        async copyCoords() {
            const coords = await postNUI('copyCoords')
            this.coords = coords
        }
    },
    props: ['setAdminActivePage'],
    async mounted() {

        const data = await postNUI('getJobs')
        this.jobs = data

    },
    computed : {
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            locales : state => state.locales,

        }),
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
    },
    components: {
        playerinformation,
        inlinesvg
    }
}