import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.158/build/three.module.js';
import * as CANNON from 'https://cdn.jsdelivr.net/npm/cannon-es@0.20.0/dist/cannon-es.js';

const canvas=document.getElementById('scene');
const renderer=new THREE.WebGLRenderer({canvas,antialias:true});
renderer.setPixelRatio(Math.min(window.devicePixelRatio,1.5));
renderer.setSize(window.innerWidth,window.innerHeight);

const scene=new THREE.Scene();
scene.background=new THREE.Color(0x0f1115);

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

const plane=new THREE.Mesh(new THREE.PlaneGeometry(40,40),new THREE.MeshStandardMaterial({color:0x333333}));
plane.rotation.x=-Math.PI/2;
scene.add(plane);

let diceMeshes=[];
let diceBodies=[];

function createDice(size=1){
  const group=new THREE.Group();
  const cube=new THREE.Mesh(new THREE.BoxGeometry(size,size,size),new THREE.MeshStandardMaterial({color:0xffffff}));
  group.add(cube);
  const pipGeo=new THREE.CircleGeometry(size*0.1,16);
  const pipMat=new THREE.MeshBasicMaterial({color:0x000000});
  function addPip(x,y,z,rx,ry){const p=new THREE.Mesh(pipGeo,pipMat);p.position.set(x,y,z);p.rotation.set(rx,ry,0);group.add(p);}
  addPip(0,0,size/2,0,0);
  addPip(-size/3,-size/3,-size/2,Math.PI,0);
  addPip(size/3,size/3,-size/2,Math.PI,0);
  scene.add(group);

  const shape=new CANNON.Box(new CANNON.Vec3(size/2,size/2,size/2));
  const body=new CANNON.Body({mass:1});
  body.addShape(shape);
  world.addBody(body);

  diceMeshes.push(group);
  diceBodies.push(body);
}

function roll(count,times){
  let total=0;
  for(let t=0;t<times;t++){
    diceBodies.forEach(b=>{
      b.position.set(Math.random()*2-1,5+Math.random()*2,Math.random()*2-1);
      b.velocity.set(Math.random()*5-2.5,5,Math.random()*5-2.5);
      b.angularVelocity.set(Math.random()*10,Math.random()*10,Math.random()*10);
      total+=Math.floor(Math.random()*6)+1;
    });
  }
  setTimeout(()=>showResult(total,count,times),2000+count*30);
}

function showResult(total,count,times){
  document.getElementById('resultText').innerText=`${count}个骰子 × ${times}次 = ${total}`;
  document.getElementById('resultModal').classList.remove('hidden');
  document.getElementById('resultBar').innerText=`结果：${total}`;
  saveHistory(total);
}

function saveHistory(val){
  let list=JSON.parse(localStorage.getItem('diceHistory')||'[]');
  list.unshift({time:new Date().toLocaleString(),val});
  if(list.length>50)list=list.slice(0,50);
  localStorage.setItem('diceHistory',JSON.stringify(list));
}

function renderHistory(){
  let list=JSON.parse(localStorage.getItem('diceHistory')||'[]');
  const el=document.getElementById('historyList');
  el.innerHTML=list.map(i=>`<div>${i.time} → ${i.val}</div>`).join('');
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
  const times=parseInt(document.getElementById('rollTimes').value);
  if(diceMeshes.length!==count){
    diceMeshes.forEach(m=>scene.remove(m));
    diceBodies.forEach(b=>world.removeBody(b));
    diceMeshes=[];diceBodies=[];
    for(let i=0;i<count;i++)createDice(0.8);
  }
  roll(count,times);
};

document.getElementById('historyBtn').onclick=()=>{renderHistory();document.getElementById('historyModal').classList.remove('hidden');};
document.getElementById('closeHistoryBtn').onclick=()=>document.getElementById('historyModal').classList.add('hidden');

document.getElementById('blessingBtn').onclick=()=>{
  document.getElementById('resultModal').classList.add('hidden');
  const text=['大吉','好运连连','财源广进','心想事成'][Math.floor(Math.random()*4)];
  document.getElementById('blessingText').innerText=text;
  document.getElementById('blessingModal').classList.remove('hidden');
};

document.getElementById('confirmBlessingBtn').onclick=()=>{
  document.getElementById('blessingModal').classList.add('hidden');
};

window.addEventListener('devicemotion',e=>{
  if(Math.abs(e.acceleration.x||0)>12)document.getElementById('rollBtn').click();
});
