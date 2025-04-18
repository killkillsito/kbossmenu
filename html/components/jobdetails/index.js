import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/jobdetails/index.html'),
    data: () => ({
        editingBusiness: false,
        businessAccessPage: [],
        selectBusiness:false,
        ranks : [],
        inventory : [],
        newLogo : null,
        vault : 0,
        coords: null,
    }),
    methods: {
       
        ChangeTheme(value){
            postNUI("changeTheme", {
                theme : value,
                companyName : getAdminSelectedCompany.company,
            });
        },
        DeleteBusiness(){
            postNUI("DeleteBusiness");
        },
        async copyCoords() {
            const coords = await postNUI('copyCoords')
            this.coords = coords
        },
        SaveChanges(){
            if (this.editingBusiness){
                this.updateBusinessAccessPage()
                this.updateBusinessLocation()
            }

        },
        updateBusinessAccessPage(){
           

            if (JSON.stringify(this.businessAccessPage) != JSON.stringify(this.getAdminSelectedCompany.pageaccess)){
                postNUI("updateBusinessAccessPage", {
                    pageaccess: this.businessAccessPage,
                    name: this.getAdminSelectedCompany.company,
                });
            }
        },
        updateBusinessLocation() {
            if (this.coords != null && JSON.stringify(this.coords) !=  JSON.stringify(this.getAdminSelectedCompany.location))  {
                postNUI("updateBusinessLocation", {
                    location: JSON.parse(this.coords),
                    name: this.getAdminSelectedCompany.company,
                });

            }
        },
        UploadNewLogo(){
            if(this.newLogo){
                postNUI("UploadNewLogo", {
                    url : this.newLogo,
                    name : this.getAdminSelectedCompany.company,
                });
                this.newLogo = null
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
        toggleBusinessAccessPage(value) {
            let find = this.businessAccessPage.find((val) => value == val)
            if (find) {
                this.businessAccessPage = this.businessAccessPage.filter((val) => value != val)

            } else {
                this.businessAccessPage.push(value)
            }
        },
        setEditingBusiness(payload) {
            this.editingBusiness = payload
        }
    },
    props: [],
    async mounted() {
        this.ranks = await postNUI("getRanksByName", {
            name : this.getAdminSelectedCompany.company,
        })
        this.inventory = await postNUI("getInventoryByName", {
            name : this.getAdminSelectedCompany.company,
        })
        this.vault = await postNUI("getVaultByName", {
            name : this.getAdminSelectedCompany.company,
        })
        
    },
    components: {
        playerinformation,
        inlinesvg
    },
    computed : {
        getRankAmount(){
            let data = this.ranks
            return data.length
        },
        getBoss(){
            let boss = ''
            this.getAdminSelectedCompany.employees.forEach(employee => {
                if(employee.rankLevel == this.getAdminSelectedCompany.bossrank){
                    boss = employee.name
                }
            });
            return boss
        },
        getCardBG() {
            if ( this.getAdminSelectedCompany.theme == "blue") {
              return `./assets/images/card-container.png`;
            } else {
              return `./assets/images/${ this.getAdminSelectedCompany.theme}/card-container.png`;
            }
          },
        ...Vuex.mapGetters({
            getAdminSelectedCompany: 'getAdminSelectedCompany',
            
        }),
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            locales : state => state.locales,

        }),
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
    },
}