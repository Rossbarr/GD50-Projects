using UnityEngine;

public class Skyscraper : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        if (transform.position.z < -40)
        {
            Destroy(gameObject);
        }        
        else
        {
            transform.Translate(0, 0, -SkyscraperSpawner.speed * Time.deltaTime);
        }
    }

    void OnTriggerEnter(Collider other)
    {
        other.transform.parent.gameObject.GetComponent<Helicopter>().Explode();
    }
}
