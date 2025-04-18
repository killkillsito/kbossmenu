import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/employeedetails/index.html'),
    data: () => ({
        showSelect:false,
        fireModal:false,
        showRankSelect:false,
        showCertificationsSelect: false,
        note : null,
        filteredLogs : '',
    
    }),
    watch:{
        'getSelectedEmployee.note'(val){
            this.note = val
        }
    },
    mounted(){
        this.note =  this.getSelectedEmployee.note
    },
    methods : {
        SaveNote(){
            if(this.note){
                postNUI("SaveNote", {
                    identifier : this.selectedEmployeeIdentifier,
                    note:this.note,
                });  

            }
        },
        SetRank(rank){
            postNUI("setRank", {
                identifier : this.selectedEmployeeIdentifier,
                rankLevel : rank.grade,
                name : rank.job_name,
            });

        },
        ToggleCertification(certification) {
            postNUI("ToggleCertification", {
                certification,
                identifier:this.selectedEmployeeIdentifier
            })
        },
        setFireModal(payload){
            this.fireModal = payload
        },
        Fire(){
            postNUI("fire", this.selectedEmployeeIdentifier);
            this.setActivePage('employees')
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
    props: ['setActivePage'],
  
    computed : {
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            selectedEmployeeIdentifier : state => state.selectedEmployeeIdentifier,
            certifications : state => state.certifications,
            ranks : state => state.ranks,
            companyData: state => state.companyData,
            locales : state => state.locales,


        }),
        getFilteredLogs(){
            if(this.filteredLogs.length > 0){
                return this.getEmplooyeLogs.filter((log) => log.message.toLowerCase().includes(this.filteredLogs.toLowerCase()))

            }
            return this.getEmplooyeLogs
        },
        getEmplooyeLogs(){
            return this.companyData.logs.filter((log) => log.identifier == this.selectedEmployeeIdentifier  )
        },
      
        formatCertifications(){
            let text = '' 
            this.getSelectedEmployee.certifications.forEach((certification, index) =>{
                const certificationData = this.certifications.find((c) => c.name == certification)                
                if(certificationData){
                    if(this.getSelectedEmployee.certifications.length == index+1){
                        text += certificationData.label + ' '
                    }else{
                        text += certificationData.label + ', '
                    }
                }
             })
             return text
        },
        ...Vuex.mapGetters({
            getSelectedEmployee: 'getSelectedEmployee',
        }),
        formattedJob(){
            return this.jobInfo.label +' - '+this.jobInfo.grade_label
        },
        otherPlayerFormattedJob(){
            return this.getSelectedEmployee.jobLabel +' - '+this.getSelectedEmployee.rankLabel
        },
    },
    components : {
        playerinformation,
        inlinesvg
    }
}