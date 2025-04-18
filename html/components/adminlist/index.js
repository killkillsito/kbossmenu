import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/adminlist/index.html'),
    data: () => ({
      
    }),
    methods : {
        SecondsToDate(seconds, includeHours) {
            const date = new Date(null);
            date.setSeconds(seconds); // specify value for SECONDS here
            let day = date.getDate()
            let month = date.getMonth() + 1
            let hours = date.getHours()
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

            return `${day}.${month}.${date.getFullYear()} ${includeHours ? formattedClock : ''}`
        },
        ...Vuex.mapMutations({
       
            setAdminSelectedBusinessName : "setAdminSelectedBusinessName",
        })
        
    },
    computed : {
        
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            companies: state => state.companies,
            locales : state => state.locales,
             
        
        }),
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
    },
    props: ['setAdminActivePage'],
    mounted(){
    },
    components : {
        playerinformation,
        inlinesvg
    }
}