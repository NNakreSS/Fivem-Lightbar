let vehicleLightbars = []
let TotalNewLights = []
let sellectLightbar = []
window.addEventListener('message', (event) => {
    const data = event.data
    const typ = data.typ
    const lbData = data.lbData
    if (typ == "UI") {
        data.status == true ? display(true) : display(false);
        if (lbData != null) {
            $('#vehLightbars').empty();
            vehicleLightbars = []
            for (let index = 0; index < lbData.length; index++) {
                const element = lbData[index];
                vehicleLightbars.push(element)
                const name = element.model
                const lightbar = element.lbEntity
                const num = index + 1
                const identity = element.vehIdentity
                $('#vehLightbars').append(`
                <div>
                <input type="radio" id="`+ lightbar + `" onclick="selectLightbar(this)" data-vehIdentity="`+identity+`" name="inputLb" value="` + name + `" checked/>
                <label for="`+ lightbar + `">` + name + " " + num + `</label>
                </div><br>
                `)
                sellectLightbar = lbData[index]
                sendPost("selectLightbar", { lightbar: lightbar })
                console.log(sellectLightbar.vehIdentity)
            }
        }
    }
})

function sendPost(typ, data) {
    $.post(`https://${GetParentResourceName()}/` + typ, JSON.stringify(data));
}

function selectLightbar(typ) {
    const lightbar = typ.getAttribute("id");
    const vehIdentity = typ.getAttribute("data-vehIdentity");
    const model = typ.getAttribute("value");
    sellectLightbar = {lightbar: lightbar , vehIdentity:vehIdentity , model: model}
    sendPost("selectLightbar", { lightbar: lightbar })
}

function display(bool) {
    bool == true ? $("#container").show("slow") : $("#container").hide("slow");
}

function addLightbar() {
    const model = $('#lightbars').val();
    sendPost("addLightbar", { modelName: model })
}

let infoButton = "yes";
let interVal
$(".button").mousedown(function () {
    const data = this.getAttribute("data-value")
    const Datatype = this.getAttribute("data-type");
    buttonClick(data,Datatype)
    if (Datatype == "move" || Datatype == "move-cam") {
            interVal = setInterval(()=>{
                buttonClick(data,Datatype)
            },50);
    }
}).bind('mouseup mouseleave',function () {
    clearInterval(interVal)
})

$('#hideCam').mouseenter(function() {
    $('#hideCam').css("left","-30px")
    $('#hideCam').css("width","50px")
}).mouseleave(function() {
    $('#hideCam').css("left","2px")
    $('#hideCam').css("width","10px")
});

let camSettingDisplay = false;
$("#hideCam").mousedown(function () {
    camSettingDisplay ? $("#camSetting").hide("slow") : $("#camSetting").show("slow");
    camSettingDisplay = !camSettingDisplay
})

function buttonClick(data,dt) {
    if (data == null) return;
    if (data == "save") {
        sendPost("clickButton", { typ: "save" })
        $('#vehLightbars').empty();
    } else if (data == "cancel") {
        display(false);
        if (TotalNewLights.length > 0) {   
            $('#alertBox p').empty();
            $('#alertBox p').append(TotalNewLights.length+"newly added lightbar do you confirm to be removed ?");
            $('#alertBox').show("slow");
        }else{
            sendPost("clickButton", { typ: "cancel" })
            $('#vehLightbars').empty();
        }
    } else if (data == "yes") {
        $('#alertBox').hide("slow");
        $('#vehLightbars').empty();
        infoButton == "yes" ? (sendPost("clickButton", { typ: "cancel" }),TotalNewLights = []) : 
        infoButton == "delete" ? sendPost("clickButton", { typ: "delete", lightbarId: sellectLightbar.vehIdentity }) : "";
        infoButton = "yes"
    } else if (data == "no") {
        $('#alertBox').hide("slow");
        display(true);
    } else if (data == "delete-main") {
        infoButton = "delete"
        display(false);
        $('#alertBox p').empty();
        $('#alertBox p').append("Do you confirm that the selected "+sellectLightbar.model+" will be removed?");
        $('#alertBox').show("slow");
    } else if (data == "delete") {
        sendPost("clickButton", { typ: "delete", lightbarId: sellectLightbar.vehIdentity })
        infoButton = "yes"
    } else {
        const speed = $("#speed").val()
        sendPost("clickButton", { typ: data, speed: speed , dt:dt})
    }
}

$(document).ready(() => {
    $("#menu").draggable()
}
)