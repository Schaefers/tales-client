import QtQuick 2.0
import Mana 1.0

Image {
    id: joystick

    width: 64
    height: 64

    smooth: false;

    source: "images/joystick_frame.png"

    readonly property real centerX: width / 2
    readonly property real centerY: height / 2

    property real targetX: centerX
    property real targetY: centerY

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: Qt.platform.os !== "android"
        onReleased: updateWalkDirection()
    }

    MultiPointTouchArea {
        id: touchArea
        anchors.fill: parent
        enabled: Qt.platform.os === "android"
        onReleased: updateWalkDirection()
        maximumTouchPoints: 1
        touchPoints: [ TouchPoint { id: touchPoint } ]
    }

    Item {
        id: dot

        function joystickPosition() {
            var maxDistance = 10;
            var moveVector = Qt.vector2d(targetX - centerX, targetY - centerY);
            var newMoveVector = moveVector.normalized().times(maxDistance);
            if (moveVector.length() > newMoveVector.length())
                moveVector = newMoveVector;

            return moveVector.plus(Qt.vector2d(centerX, centerY));
        }

        x: joystickPosition().x;
        y: joystickPosition().y;

        Image {
            source: "images/joystick.png";
            anchors.centerIn: parent;
            smooth: false;
        }
    }

    Binding {
        when: joystick.state != ""
        target: gameClient
        property: "playerWalkDirection"
        value: {
            var dx = targetX - centerX;
            var dy = targetY - centerY;
            var walkX = Math.abs(dx) > 15;
            var walkY = Math.abs(dy) > 15;

            if (!walkX && !walkY && gameClient.player) {
                gameClient.lookAt(gameClient.player.x + dx,
                                  gameClient.player.y + dy);
            }

            Qt.point(walkX ? dx : 0,
                     walkY ? dy : 0);
        }
    }

    states: [
        State {
            name: "mouseAreaPressed"
            when: mouseArea.pressed
            PropertyChanges {
                target: joystick
                targetX: mouseArea.mouseX
                targetY: mouseArea.mouseY
            }
        },
        State {
            name: "touchPointPressed"
            when: touchPoint.pressed
            PropertyChanges {
                target: joystick
                targetX: touchPoint.x
                targetY: touchPoint.y
            }
        }
    ]
}
