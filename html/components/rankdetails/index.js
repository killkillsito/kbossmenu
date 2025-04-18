import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/rankdetails/index.html'),
    data: () => ({
       currentPermissionPage : false,
       deleteModal:false,
    }),
    methods : {
        ...Vuex.mapMutations({
            setSelectedRank: 'setSelectedRank',
            setSelectedEmployeeIdentifier : 'setSelectedEmployeeIdentifier',
        }),
        EmployeeDetails(identifier) {
            this.setSelectedEmployeeIdentifier(identifier)
            this.setActivePage('employeedetails')
        },
        setDeleteModal(payload){
            this.deleteModal = payload
        },
        setCurrentPermissionPage(payload){
            if( this.currentPermissionPage == payload) {
                this.currentPermissionPage = false
                return
            }
            this.currentPermissionPage = payload
        },
        togglePermission(name){
                postNUI("togglePermission", {
                name,
                rank : this.getSelectedRankData.grade,
            });
            
        },
    },
    props: ['setActivePage'],
    async mounted() {



    },
    components : {
        playerinformation,
        inlinesvg
    },

    computed : {
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            selectedRank : state => state.selectedRank,
            companyData: state => state.companyData,
            ranks : state => state.ranks,
            locales : state => state.locales,
            permissions : state => state.permissions,
        }),
        getEmployees(){
            
           
            return   this.companyData.employees.filter((employee) => employee.rankLevel == this.getSelectedRankData.grade)
        },

        getSelectedRankData(){
            return this.ranks.find((rank) => rank.grade == this.selectedRank)
        },
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
    },
}