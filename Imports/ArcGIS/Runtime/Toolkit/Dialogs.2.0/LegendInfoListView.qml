/*******************************************************************************
 * Copyright 2012-2016 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.6
import QtQuick.Layouts 1.3
import Esri.ArcGISExtras 1.1

Item {
    id: view

    // user configurable properties
    property color borderColor: "#000000"
    property color backgroundColor: "#E0E0E0"
    property color layerNameBackgroundColor: "#00BCD4"
    property color textColor: "#000000"
    property color sectionTextColor: textColor
    property color titleTextColor: textColor
    property color sectionBackgroundColor: "#90A4AE"
    property real titleFontPixelSize: width / 8
    property real textFontPixelSize: width / 15
    property real itemSpacing: 35 * scaleFactor
    property int borderWidth: 1
    property int cornerRadius: 1
    property string expandButtonImageUrl: ""
    property string title: "Legend"
    property bool propagateMouseActions: false
    property var model

    // internal properties
    property real scaleFactor: System.displayScaleFactor
    property bool expanded: true

    Rectangle {
        id: outerRectangle
        height: parent.height
        width: parent.width
        color: backgroundColor
        opacity: parent.opacity
        radius: cornerRadius

        border {
            color: borderColor
            width: borderWidth
        }

        Behavior on height {
            SpringAnimation {
                spring: 3
                damping: 4
            }
        }

        state: "expanded"

        states: [
            State {
                name: "expanded"
                PropertyChanges { target: outerRectangle; height: parent.height }
                PropertyChanges { target: view; expanded: true }
            },

            State {
                name: "unexpanded"
                PropertyChanges { target: outerRectangle; height: topBar.height + 10 * scaleFactor }
                PropertyChanges { target: view; expanded: false }
            }
        ]

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = !propagateMouseActions
            onWheel: wheel.accepted = !propagateMouseActions
        }

        Column {
            id: column
            anchors {
                fill: parent
                margins: 5 * scaleFactor
            }
            spacing: 10 * scaleFactor
            width: parent.width

            GridLayout {
                id: topBar
                width: parent.width
                rows: 1
                columns: 2

                Rectangle {
                    anchors.left: parent.left
                    width: parent.width - buttonImage.width - 10 * scaleFactor
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        text: qsTr(title)
                        width: parent.width
                        clip: true
                        elide: Text.ElideRight
                        color: titleTextColor
                        font {
                            pixelSize: titleFontPixelSize
                            bold: true
                        }
                    }
                }

                // expand the legend
                Rectangle {
                    anchors.right: parent.right
                    height: titleFontPixelSize
                    color: buttonImage.visible ? "transparent" : (outerRectangle.state === "expanded" ? "#757575" : "darkgray")
                    width: height
                    radius: 100

                    // if an image url has been set
                    Image {
                        id: buttonImage
                        anchors.fill: parent
                        visible: expandButtonImageUrl !== ""
                        source: expandButtonImageUrl
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            outerRectangle.state === "expanded" ? outerRectangle.state = "unexpanded" : outerRectangle.state = "expanded";
                        }
                    }
                }
            }

            // display the legend information
            ListView {
                id: legendListView
                anchors.margins: 10 * scaleFactor
                width: parent.width
                height: parent.height - topBar.height - 15 * scaleFactor
                model: view.model
                clip: true

                delegate: Item {
                    width: parent.width
                    height: itemSpacing

                    Row {
                        spacing: 5 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: symbol
                            width: symbolWidth * scaleFactor
                            height: symbolHeight * scaleFactor
                            source: symbolUrl
                        }

                        Text {
                            width: legendListView.width - symbol.width
                            text: name
                            wrapMode: Text.WordWrap
                            renderType: Text.NativeRendering
                            font.pixelSize: textFontPixelSize
                            color: textColor

                        }
                    }
                }

                section {
                    property: "layerName"
                    criteria: ViewSection.FullString
                    labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels

                    delegate: Rectangle {
                        width: parent.width
                        height: childrenRect.height
                        color: sectionBackgroundColor

                        Text {
                            text: section
                            font {
                                bold: true
                                pixelSize: textFontPixelSize
                            }
                            color: sectionTextColor
                            renderType: Text.NativeRendering
                        }

                    }
                }
            }

        }
    }
}
