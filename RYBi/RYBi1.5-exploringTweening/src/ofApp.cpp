#include "ofApp.h"
#include <cmath>
#include <string>

const string DATE_FORMAT = "%Y-%m-%d";

//--------------------------------------------------------------
void ofApp::setup(){
    gui.setup();
    gui.add(speed.set("speed", 500., 100., 5000.));
    Poco::DateTime firstOfYear(2020, 1, 1);
    Poco::DateTime lastOfApril(2020, 4, 30);
    firstDate = firstOfYear.timestamp();
    lastDate = lastOfApril.timestamp();
    numDays = (lastOfApril - firstOfYear).days();

    font.load("Roboto-Medium.ttf", 16);
}

//--------------------------------------------------------------
void ofApp::update(){
    time = ofGetElapsedTimeMillis();
    index = ceil(fmod(time / speed, numDays));
    // adjustedValue = 1. + remainder(time, index);
    adjustedValue = fmod(time, speed) / speed;
    selectedDate = firstDate + Poco::Timespan(index, 0, 0, 0, 0);
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofSetColor(ofColor::white);
    string label = Poco::DateTimeFormatter::format(selectedDate, DATE_FORMAT);
    auto bbox = font.getStringBoundingBox(label, 0., 0.);
    float x = ofGetWidth() / 2. - bbox.width / 2.;
    float y = ofGetHeight() / 2. - bbox.height / 2.;
    font.drawString(std::to_string(index), x, y);
    font.drawString(std::to_string(adjustedValue), x, y - bbox.height-10.);
    ofDrawRectangle(x, y + bbox.height, bbox.width * adjustedValue, 25.);
    ofSetColor(ofColor::red);
    ofDrawLine( x + bbox.width, y+bbox.height, x + bbox.width, y+bbox.height+25.);

    gui.draw();
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
