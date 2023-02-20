using UnityEngine;
using UnityEngine.Rendering;

public class BoxShadow : MonoBehaviour
{
    public RenderTexture ShadowRT;
    public Renderer ShadowTarget;
    public Shader ShadowShader;
    public Light DirectionLight;
    
    private Material shadowMat;
    private CommandBuffer cmd;
    private Matrix4x4 ProjectionMatrix = new Matrix4x4( new Vector4(2f, 0, 0, 0),
        new Vector4(0, 2f, 0, 0),
        new Vector4(0, 0, 2f, 0),
        new Vector4(0, 0, 0, 1));

    private void OnEnable()
    {
        shadowMat = new Material(ShadowShader);
        cmd = new CommandBuffer();
        ShadowRT = RenderTexture.GetTemporary(128,128);
        GetComponent<MeshRenderer>().sharedMaterial.mainTexture = ShadowRT;
    }

    private void OnDisable()
    {
        Destroy(shadowMat);
        shadowMat = null;
        cmd = null;
        RenderTexture.ReleaseTemporary(ShadowRT);
    }

    void Update()
    {
        if (DirectionLight)
        {
            transform.rotation = DirectionLight.transform.rotation;
        }
        DrawShadow();
    }

    private void DrawShadow()
    {
        cmd.SetRenderTarget(ShadowRT);
        cmd.ClearRenderTarget(false, true,Color.black);
        
        // 正交
        cmd.SetProjectionMatrix(ProjectionMatrix);
        var worldToLocal = transform.worldToLocalMatrix;
        worldToLocal.m23 += 0.5f; 
        cmd.SetViewMatrix(worldToLocal);
        cmd.DrawRenderer(ShadowTarget, shadowMat);
        
        Graphics.ExecuteCommandBuffer(cmd);
        
        cmd.Clear();
    }
}
