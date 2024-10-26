using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class createSpheres : MonoBehaviour
{
    public GameObject _gameObject;
    public int _size;
    private void OnEnable()
    {
        for (int i = 0; i < _size; i++)
        {
            for (int j = 0; j < _size; j++)
            {
                GameObject sphere = Instantiate(_gameObject);
                sphere.transform.position = new Vector3(i * 2, 0, j * 2);
                sphere.transform.SetParent(gameObject.transform);
                sphere.name = (_size * i + j).ToString();
                //sphere.GetComponent<PerObjectMaterialProperties>().baseColor = new Color(Random.Range(0.0f, 1),
                //    Random.Range(0.0f, 1), Random.Range(0.0f, 1));
            }
        }
        gameObject.name = "sphere " + (_size * _size).ToString();
    }
}
