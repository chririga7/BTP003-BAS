sap.ui.define(
    ["sap/ui/core/mvc/ControllerExtension", "sap/ui/core/message/Message", "sap/ui/core/message/MessageType"],
    function (ControllerExtension, Message, MessageType) {
        "use strict";

        // Avviso fisso nell'intestazione delle Object Page piattaforma (CONFIG_FRAMEWORK §6.5, story 15.C8).
        // Va rimostrato a ogni binding: Fiori Elements tiene lo stato della fascia per contesto (attivo/bozza).
        return ControllerExtension.extend("z.doc.platform.adminplatform.ext.ProviderNotice", {
            override: {
                routing: {
                    onAfterBinding: function () {
                        const text = this.base.getView().getModel("i18n").getResourceBundle().getText("providerNotice");
                        this.base.getExtensionAPI().showMessages([
                            new Message({ message: text, type: MessageType.Information })
                        ]);
                    }
                }
            }
        });
    }
);
