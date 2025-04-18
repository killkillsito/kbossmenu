import importTemplate from '../../util/importTemplate.js';
import inlinesvg from '../../util/inlineSvg.js';
import playerinformation from '../playerinformation/index.js';
export default {
    template: await importTemplate('components/outfit/index.html'),
    data: () => ({
        hasPermission : true,
        selectedOutfit: false,
        prevPresetCodeCode : false,
        deleteModal :false,
        addDressCode : false,
        presetName : '',
        selectedOutfitIndex : false,
        editDressCode : false,
        filteredOutfits : '',
        newDressCode : {
            jacket : {
                val : 14,
                tex : 12,
            },
            shirt : {
                val : 14,
                tex : 12,
            },
            hands : {
                val : 14,
                tex : 12,
            },
            pants : {
                val : 14,
                tex : 12,
            },
            shoes : {
                val : 14,
                tex : 12,
            },
            mask : {
                val : 14,
                tex : 12,
            },
            chain : {
                val : 14,
                tex : 12,
            },
            decals : {
                val : 14,
                tex : 12,
            },
            helmet : {
                val : 14,
                tex : 12,
            },
            glasses : {
                val : 14,
                tex : 12,
            },
            watches : {
                val : 14,
                tex : 12,
            },
            bracelets : {
                val : 14,
                tex : 12,
            },
        },
    }),
    watch:{
   
    },
    methods : {
        wearOriginalClothes(){
            postNUI("wearOriginalClothes")
        },
        OpenClothingMenu(){
            postNUI("openClothingMenu")
        },
        setDeleteModal(payload){
            this.deleteModal = payload
        },
        SaveOutfit(){
            postNUI('SaveOutfit', {
                dressCode : this.newDressCode,
                presetName : this.presetName,

            })

        },
        WearClothes(){
            postNUI('WearClothes', this.selectedOutfit.preset_code)
        },
        DeleteClothes(){
            postNUI('DeleteClothes', this.selectedOutfit.id)
            this.selectedOutfit = false
            this.setDeleteModal(false)
        },
        SaveEditPreset(){
            postNUI('EditPreset', this.selectedOutfit)
            this.selectedOutfit = false
        },
    },
    props: ['setCurrentAction', 'currentAction', 'setActivePage'],
    mounted(){
        
    },
    computed : {
        ...Vuex.mapState({
            playerInfo : state => state.playerInfo,
            jobInfo : state => state.jobInfo,
            companyData: state => state.companyData,
            locales : state => state.locales,


        }),
        getFilteredOutfits(){
            if(this.filteredOutfits.length > 0){
                return this.companyData.outfits.filter((outfit) => outfit.name.toLowerCase().includes(this.filteredOutfits.toLowerCase()))

            }
            return this.companyData.outfits
        },
        formattedJob(){
            return this.jobInfo.label +'-'+this.jobInfo.grade_label
        },
    },
    components : {
        playerinformation,
        inlinesvg
    }
}