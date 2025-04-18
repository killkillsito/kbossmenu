import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/logs/index.html'),
    data: () => ({
        filteredLogs : ''
    }),
    methods : {
        ClearLogs(){
            postNUI('ClearLogs')
        },
        SecondsToDate(seconds, includeHours) {
            const date = new Date(null);
            date.setSeconds(seconds); // specify value for SECONDS here
            let day = date.getDate()
            let month = date.getMonth() + 1
            let hours = date.getHours()+1
            let minutes = date.getMinutes()
            if (minutes < 10) {
                minutes = '0' + minutes
            }
            if (hours < 10) {
                hours = '0' + hours
            }
            if (day < 10) {
                day = '0' + day
            }
            if (month < 10) {
                month = '0' + month
            }

            let formattedClock = `${hours}:${minutes}`

            return `${day}.${month}.${date.getFullYear()} ${ formattedClock }`
        },
    },
    props: ['setCurrentAction', 'currentAction', 'setActivePage'],
    mounted(){
        this.companyData.logs.sort((a, b) => b.date - a.date)
    },
    components : {
        playerinformation,
        inlinesvg
    },
    computed : {
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            companyData: state => state.companyData,
            locales : state => state.locales,

        }),
        getFilteredLogs(){
            if(this.filteredLogs.length > 0){
                return this.companyData.logs.filter((log) => log.message.toLowerCase().includes(this.filteredLogs.toLowerCase()))

            }
            return this.companyData.logs
        },
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
    },
}