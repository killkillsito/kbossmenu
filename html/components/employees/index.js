import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/employees/index.html'),
    data: () => ({
        showSelect: false,
        playerId : null,
        playerPP : false,
        playerName : false,
        filteredEmployee : '',
        selectedRank : {
            label : '',
            rank : null,
        }
    }),
    computed: {
        ...Vuex.mapState({
            companyData: state => state.companyData,
            selectedEmployeeIdentifier : state => state.selectedEmployeeIdentifier,
            ranks : state => state.ranks,
            locales : state => state.locales,

        }),
        GetOnlineNum() {
            return this.companyData.employees?.filter((employee) => employee.online == 1).length
        },
        GetOfflineNum() {
            return this.companyData.employees?.filter((employee) => employee.online == 0).length
        },
        ...Vuex.mapState({
            playerInfo: state => state.playerInfo,
            jobInfo: state => state.jobInfo,
        }),
        formattedJob() {
            return this.jobInfo.label + '-' + this.jobInfo.grade_label
        },
        getFilteredEmployees(){
            if(this.filteredEmployee.length > 0){
                return this.companyData.employees?.filter((employee) => employee.name.toLowerCase().includes(this.filteredEmployee.toLowerCase()))

            }
            return this.companyData?.employees
        },
    },
    methods: {
        ...Vuex.mapMutations({
            setSelectedEmployeeIdentifier: 'setSelectedEmployeeIdentifier',
        }),
        SelectRank(grade, label){
            this.selectedRank.label = label
            this.selectedRank.grade = grade

        },
        Recruit(){
            if(this.selectedRank.label && this.selectedRank.grade){

                postNUI('SelectRank', {
                    grade:this.selectedRank.grade,
                    id:this.playerId,
                })
            }
        },
        EmployeeDetails(identifier) {
            
            this.setSelectedEmployeeIdentifier(identifier)
            if(this.activeMenu == 'admin'){
                this.setAdminActivePage('employeedetails')

            }else{
                this.setActivePage('employeedetails')
            }
        },
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
    },
    watch:{
         async playerId(val){
            if(val.length > 0 && !isNaN(val)){
                const resp = await postNUI("getPlayerPP", val)
                const _resp = await postNUI("getPlayerName", val)
                if(_resp){
                    this.playerName = _resp
                }
                if(resp){
                    this.playerPP = resp
                    return val
                }

            }
            this.playerPP = false
            
        }
    },
    props: ['setCurrentAction', 'currentAction', 'setActivePage', 'activeMenu', 'setAdminActivePage'],
 
    components: {
        playerinformation,
        inlinesvg
    }
}