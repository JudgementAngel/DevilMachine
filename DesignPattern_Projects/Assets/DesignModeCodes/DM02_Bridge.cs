using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DM
{
    public class DM02_Bridge : MonoBehaviour
    {

        // Use this for initialization
        void Start()
        {
            IRenderEngine renderEngine = new DirectX();
            Sphere sphere = new Sphere(renderEngine);
            sphere.Draw();
            Cube cube = new Cube(renderEngine);
            cube.Draw();
        }

        // Update is called once per frame
        void Update()
        {

        }
    }

    public class IShape
    {
        public string name;
        public IRenderEngine renderEngine;

        public IShape(IRenderEngine renderEngine)
        {
            this.renderEngine = renderEngine;
        }

        public void Draw()
        {
            renderEngine.Render(name);
        }
    }

    public class Sphere : IShape
    {
        public Sphere(IRenderEngine renderEngine):base(renderEngine)
        {
            name = "Sphere";
        }

        //public OpenGL openGL = new OpenGL();

        //public void Draw()
        //{
        //    openGL.Render(name);
        //}
    }

    public class Cube : IShape
    {
        public Cube(IRenderEngine renderEngine) : base(renderEngine)
        {
            name = "Cube";
        }

        //public OpenGL openGL = new OpenGL();

        //public void Draw()
        //{
        //    openGL.Render(name);
        //}
    }

    public class Capsule : IShape
    {
        public Capsule(IRenderEngine renderEngine) : base(renderEngine)
        {
            name = "Capsule";
        }
        //public OpenGL openGL = new OpenGL();

        //public void Draw()
        //{
        //    openGL.Render(name);
        //}
    }

    public abstract class IRenderEngine
    {
        public abstract void Render(string name);
    }

    public class OpenGL : IRenderEngine
    {
        public override void Render(string name)
        {
            BaseLog.Log(name + "is Render in OpenGL!");
        }
    }

    public class DirectX : IRenderEngine
    {
        public override void Render(string name)
        {
            BaseLog.Log(name + "is Render in DirectX!");
        }
    }
}