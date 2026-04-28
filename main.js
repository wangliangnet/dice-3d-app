import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.158/build/three.module.js';
import * as CANNON from 'https://cdn.jsdelivr.net/npm/cannon-es@0.20.0/dist/cannon-es.js';

const canvas=document.getElementById('scene');
const renderer=new THREE.WebGLRenderer({canvas,antialias:true});
renderer.setSize(window.innerWidth,window.innerHeight);

const scene=new THREE.Scene();
scene.background=new THREE.Color(0x111111);

const camera=new THREE.PerspectiveCamera(60,window.innerWidth/window.innerHeight,0.1,100);
camera.position.set(6,6,8);
camera.lookAt(0,0,0);

const light=new THREE.DirectionalLight(0xffffff,1);
light.position.set(5,10,5);
scene.add(light);

const world=new CANNON.World();
world.gravity.set(0,-9.82,0);

const groundBody=new CANNON.Body({mass:0});
groundBody.addShape(new CANNON.Plane());
groundBody.quaternion.setFromEuler(-Math.PI/2,0,0);
world.addBody(groundBody);

const plane=new THREE.Mesh(new THREE.PlaneGeometry(20,20),new THREE.MeshStandardMaterial({color:0x444444}));
plane.rotation.x=-Math.PI/2;
scene.add(plane);

let diceMeshes=[];
let diceBodies=[];

function createDice(){
  const geo=new THREE.BoxGeometry(1,1,1);
  const mat=new THREE.MeshStandardMaterial({color:0xffffff});
  const mesh=new THREE.Mesh(geo,mat);
  scene.add(mesh);

  const shape=new CANNON.Box(new CANNON.Vec3(0.5,0.5,0.5));
  const body=new CANNON.Body({mass:1});
  body.addShape(shape);
  world.addBody(body);

  diceMeshes.push(mesh);
  diceBodies.push(body);
}

function roll(){
  diceBodies.forEach(b=>{
    b.position.set(Math.random()*2-1,5+Math.random()*2,Math.random()*2-1);
    b.velocity.set(Math.random()*5-2.5,5,Math.random()*5-2.5);
    b.angularVelocity.set(Math.random()*10,Math.random()*10,Math.random()*10);
  });
}

function animate(){
  requestAnimationFrame(animate);
  world.step(1/60);
  diceMeshes.forEach((m,i)=>{
    m.position.copy(diceBodies[i].position);
    m.quaternion.copy(diceBodies[i].quaternion);
  });
  renderer.render(scene,camera);
}
animate();

document.getElementById('rollBtn').onclick=()=>{
  const count=parseInt(document.getElementById('diceCount').value);
  if(diceMeshes.length===0){
    for(let i=0;i<count;i++)createDice();
  }
  roll();
};
